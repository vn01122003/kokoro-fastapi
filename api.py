"""
Vercel handler for Kokoro FastAPI
"""
import os
import sys
from pathlib import Path

# Add the api/src directory to Python path
api_src_path = Path(__file__).parent / "api" / "src"
sys.path.insert(0, str(api_src_path))

# Import the FastAPI app
from api.src.main import app

# Vercel handler
def handler(request):
    from mangum import Mangum
    asgi_handler = Mangum(app)
    return asgi_handler(request)
