# Code 1: Frontend — Original FastAPI-Based Interface (Mimicking UI Layer)

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
import httpx
import time

app = FastAPI(title="MCP Agent API")

class Tool(BaseModel):
    name: str
    when_to_use: str

class QueryPayload(BaseModel):
    query: str
    tools: List[Tool]

@app.post("/query")
async def handle_query(payload: QueryPayload):
    query = payload.query
    tools = payload.tools

    prompt = (
        "You are an AI agent that receives a user query along with a list of available tools. \n"
        "Process the query to determine which tool (if any) should be used based on the content of the query.\n"
        "Return a JSON payload with the following structure:\n\n"
        "{\n"
        "  'chosen_tool': '<tool name or none>',\n"
        "  'details': '<reason for choosing the tool>',\n"
        "  'timestamp': '<current timestamp in YYYY-MM-DD HH:MM:SS format>'\n"
        "}\n\n"
        "Available Tools:\n" +
        "\n".join([f"- {tool.name}: {tool.when_to_use}" for tool in tools]) +
        "\n\nMake sure to follow these instructions explicitly."
    )

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "http://localhost:8000/tools/process_query",
                json={"query": query, "tools": [tool.dict() for tool in tools]}
            )
            result = response.json()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])

    return result

# Code 2: Backend Server 1 — Handle Query, Generate SQL, Execute DB Query

from mcp.server.fastmcp import FastMCP, Context
from pydantic import BaseModel
from typing import List, Dict
import time

from db_query import generate_sql_query_with_llm, execute_query

mcp = FastMCP("MCP-Query-Server")

class Tool(BaseModel):
    name: str
    when_to_use: str

@mcp.tool(title="Process Query", description="Generate SQL, query DB and return structured result")
async def process_query(query: str, tools: List[Dict], ctx: Context) -> dict:
    sql_query = generate_sql_query_with_llm(query)

    if not sql_query:
        return {
            "llm_response": {
                "chosen_tool": "none",
                "details": "Failed to generate SQL query.",
                "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
            }
        }

    db_results, db_error = execute_query(sql_query)

    if db_error:
        details = f"Database error: {db_error}"
    else:
        details = str(db_results)

    return {
        "llm_response": {
            "chosen_tool": "database",
            "details": details,
            "timestamp": time.strftime("%Y-%m-%d %H:%M:%S")
        }
    }

if __name__ == "__main__":
    mcp.run(transport="streamable-http")

# Code 3: Backend Server 2 — Refine Response using LLM

from mcp.server.fastmcp import FastMCP, Context
from pydantic import BaseModel
import time

mcp = FastMCP("MCP-Refinement-Server")

class LLMResponse(BaseModel):
    chosen_tool: str
    details: str
    timestamp: str

@mcp.tool(title="Refine LLM Response", description="Refines the raw tool output for final display")
async def refine_response(raw_response: LLMResponse, ctx: Context) -> dict:
    refined_details = (
        f"Tool Used: {raw_response.chosen_tool}\n"
        f"Details: {raw_response.details}\n"
        f"Timestamp: {raw_response.timestamp}"
    )

    return {
        "frontend_response": {
            "summary": refined_details,
            "acknowledgement": "Here is your result, processed and formatted."
        }
    }

if __name__ == "__main__":
    mcp.run(transport="streamable-http")
