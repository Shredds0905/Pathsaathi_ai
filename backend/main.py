"""
PathSaathi AI — FastAPI Backend
================================
Run locally:   uvicorn main:app --reload
Deploy:        Railway / Render / Google Cloud Run
"""

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List
import httpx
import os
import json
import logging
from datetime import datetime

# ── App Setup ─────────────────────────────────────────────────────────────────
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="PathSaathi AI API",
    description="Backend for PathSaathi AI — Multilingual Learning Ecosystem",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Config ────────────────────────────────────────────────────────────────────
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "YOUR_GEMINI_API_KEY_HERE")
GEMINI_BASE_URL = "https://generativelanguage.googleapis.com/v1beta"
GEMINI_MODEL = "gemini-2.0-flash"

# ── Pydantic Models ───────────────────────────────────────────────────────────

class ChatMessage(BaseModel):
    role: str  # "user" | "model"
    content: str

class ChatRequest(BaseModel):
    messages: List[ChatMessage]
    language: str = "en"
    subject: Optional[str] = None
    user_name: Optional[str] = None

class ChatResponse(BaseModel):
    response: str
    suggestions: List[str] = []
    timestamp: str

class LessonRequest(BaseModel):
    topic: str
    subject: str
    language: str = "en"
    difficulty: str = "beginner"
    grade_level: int = 8

class QuizRequest(BaseModel):
    topic: str
    content: str
    language: str = "en"
    difficulty: str = "beginner"
    num_questions: int = 5

class CareerRequest(BaseModel):
    interests: List[str]
    education: str
    marks_range: str
    skills: List[str] = []
    financial_background: str = "Low Income"
    location: str = "India"
    language: str = "en"

class SummarizeRequest(BaseModel):
    content: str
    language: str = "en"
    max_points: int = 5

class TranslateRequest(BaseModel):
    content: str
    target_language: str
    preserve_formatting: bool = True

class OCRRequest(BaseModel):
    extracted_text: str
    language: str = "en"
    subject: Optional[str] = None

# ── Gemini Helper ─────────────────────────────────────────────────────────────

async def call_gemini(contents: list, temperature: float = 0.7, max_tokens: int = 2048) -> str:
    """Call Gemini API and return text response."""
    url = f"{GEMINI_BASE_URL}/models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"
    
    payload = {
        "contents": contents,
        "generationConfig": {
            "temperature": temperature,
            "maxOutputTokens": max_tokens,
            "topP": 0.95,
        },
        "safetySettings": [
            {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
            {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_MEDIUM_AND_ABOVE"},
        ],
    }
    
    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(url, json=payload)
        
    if response.status_code != 200:
        logger.error(f"Gemini API error: {response.status_code} — {response.text}")
        raise HTTPException(status_code=502, detail=f"AI service error: {response.status_code}")
    
    data = response.json()
    candidates = data.get("candidates", [])
    if not candidates:
        raise HTTPException(status_code=502, detail="Empty response from AI")
    
    return candidates[0]["content"]["parts"][0]["text"]


def build_system_prompt(language: str, subject: Optional[str]) -> str:
    lang_instruction = (
        "Respond in clear, simple English."
        if language == "en"
        else f"Respond primarily in {language}. For technical/scientific terms, use the English term and explain it in {language}."
    )
    subject_hint = f"The student is studying {subject}. " if subject else ""
    return f"""You are PathSaathi AI, a friendly AI learning assistant for Indian students — especially first-generation learners, rural students, and government school students.

Your teaching style:
- Use simple, clear language
- Always use Indian examples (cricket, festivals, food, farming, local stories)
- Be encouraging — never make students feel bad for not knowing something
- Break complex concepts into small, digestible parts
- {lang_instruction}
- {subject_hint}Format responses clearly with headings and bullet points
- Always end with 'Hope this helps! 😊 Ask me anything else.'"""


# ── Health Check ──────────────────────────────────────────────────────────────

@app.get("/")
async def root():
    return {
        "status": "ok",
        "app": "PathSaathi AI API",
        "version": "1.0.0",
        "timestamp": datetime.utcnow().isoformat(),
    }

@app.get("/health")
async def health():
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}


# ── Chat Endpoint ─────────────────────────────────────────────────────────────

@app.post("/api/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    """Main AI chat endpoint with conversation history."""
    system_prompt = build_system_prompt(request.language, request.subject)
    
    contents = [
        {"role": "user", "parts": [{"text": system_prompt}]},
        {"role": "model", "parts": [{"text": "Understood! I'm PathSaathi AI, your personal learning assistant. How can I help you today? 😊"}]},
    ]
    
    # Add conversation history (last 20 messages)
    for msg in request.messages[-20:]:
        contents.append({
            "role": msg.role,
            "parts": [{"text": msg.content}],
        })
    
    response_text = await call_gemini(contents)
    
    # Generate suggestions
    suggestions = await _get_suggestions(
        request.messages[-1].content if request.messages else "",
        request.subject or "general",
        request.language,
    )
    
    return ChatResponse(
        response=response_text,
        suggestions=suggestions,
        timestamp=datetime.utcnow().isoformat(),
    )


async def _get_suggestions(last_message: str, subject: str, language: str) -> List[str]:
    try:
        prompt = f"""Based on this student's question about {subject}: "{last_message[:200]}"
Suggest 3 natural follow-up questions.
Return ONLY a JSON array: ["question1", "question2", "question3"]
Keep questions simple and in {language}."""
        
        contents = [{"role": "user", "parts": [{"text": prompt}]}]
        response = await call_gemini(contents, temperature=0.7, max_tokens=200)
        
        json_str = response.strip()
        if json_str.startswith("```"):
            json_str = json_str.replace("```json", "").replace("```", "").strip()
        
        return json.loads(json_str)
    except Exception:
        return [
            "Can you explain this more simply?",
            "Give me an example",
            "Create a quiz on this topic",
        ]


# ── Lesson Generation ─────────────────────────────────────────────────────────

@app.post("/api/lesson/generate")
async def generate_lesson(request: LessonRequest):
    """Generate a complete lesson with flashcards and key points."""
    prompt = f"""Generate a complete educational lesson:
- Topic: {request.topic}
- Subject: {request.subject}
- Language: {request.language}
- Difficulty: {request.difficulty}
- Grade Level: {request.grade_level}

Return a JSON object:
{{
  "title": "Lesson title",
  "content": "Full markdown lesson content with headings, examples, and local Indian analogies",
  "summary": "2-3 sentence summary",
  "keyPoints": ["point1", "point2", "point3", "point4", "point5"],
  "flashcards": [
    {{"id": "f1", "front": "Question", "back": "Answer"}},
    {{"id": "f2", "front": "Question", "back": "Answer"}}
  ],
  "durationMinutes": 15
}}

Use simple language and real-world Indian examples (chai, roti, cricket, festivals).
Return ONLY the JSON, no other text."""
    
    contents = [{"role": "user", "parts": [{"text": prompt}]}]
    response_text = await call_gemini(contents, temperature=0.4, max_tokens=4096)
    
    try:
        json_str = response_text.strip()
        if json_str.startswith("```"):
            json_str = json_str.replace("```json", "").replace("```", "").strip()
        return json.loads(json_str)
    except Exception:
        return {
            "title": request.topic,
            "content": response_text,
            "summary": f"AI-generated lesson on {request.topic}",
            "keyPoints": [],
            "flashcards": [],
            "durationMinutes": 15,
        }


# ── Quiz Generation ───────────────────────────────────────────────────────────

@app.post("/api/quiz/generate")
async def generate_quiz(request: QuizRequest):
    """Generate quiz questions for a topic."""
    prompt = f"""Generate {request.num_questions} quiz questions:
Topic: {request.topic}
Content: {request.content[:800]}
Language: {request.language}
Difficulty: {request.difficulty}

Return a JSON array:
[
  {{
    "id": "q1",
    "question": "Question text",
    "type": "mcq",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctIndex": 0,
    "explanation": "Why this is correct",
    "points": 10
  }}
]
Return ONLY the JSON array."""
    
    contents = [{"role": "user", "parts": [{"text": prompt}]}]
    response_text = await call_gemini(contents, temperature=0.3, max_tokens=2048)
    
    try:
        json_str = response_text.strip()
        if json_str.startswith("```"):
            json_str = json_str.replace("```json", "").replace("```", "").strip()
        return json.loads(json_str)
    except Exception:
        raise HTTPException(status_code=500, detail="Failed to parse quiz response")


# ── Career Guidance ───────────────────────────────────────────────────────────

@app.post("/api/career/guidance")
async def career_guidance(request: CareerRequest):
    """Generate AI career guidance for Indian students."""
    prompt = f"""You are a career counsellor helping Indian students from rural/first-generation backgrounds.

Student Profile:
- Interests: {", ".join(request.interests)}
- Education: {request.education}
- Marks: {request.marks_range}
- Skills: {", ".join(request.skills) if request.skills else "Not specified"}
- Financial Background: {request.financial_background}
- Location: {request.location}
- Language: {request.language}

Provide:
1. **Top 3 Career Options** (match %, salary range, steps)
2. **Free/Low-cost Courses** (SWAYAM, NPTEL, Coursera free)
3. **Government Scholarships** (NSP, state scholarships)
4. **Government Skill Schemes** (PMKVY, NAPS, Digital India)
5. **Inspiring Role Models** from similar backgrounds
6. **6-month Roadmap**

Be encouraging, realistic, specific to Indian context. Reply in {request.language}."""
    
    contents = [{"role": "user", "parts": [{"text": prompt}]}]
    response_text = await call_gemini(contents, temperature=0.6, max_tokens=3000)
    
    return {
        "guidance": response_text,
        "interests": request.interests,
        "education": request.education,
        "generated_at": datetime.utcnow().isoformat(),
    }


# ── Summarize ─────────────────────────────────────────────────────────────────

@app.post("/api/summarize")
async def summarize(request: SummarizeRequest):
    """Summarize content in the specified language."""
    prompt = f"""Summarize the following content in {request.language} with exactly {request.max_points} key bullet points.
Use simple language a student can understand. Format as a numbered list.

Content: {request.content[:3000]}"""
    
    contents = [{"role": "user", "parts": [{"text": prompt}]}]
    response_text = await call_gemini(contents, temperature=0.3)
    
    return {"summary": response_text, "language": request.language}


# ── Translate ─────────────────────────────────────────────────────────────────

@app.post("/api/translate")
async def translate(request: TranslateRequest):
    """Translate educational content to target language."""
    prompt = f"""Translate the following educational content to {request.target_language}.
{"Preserve markdown formatting (headings, bold, lists)." if request.preserve_formatting else ""}
Keep technical/scientific terms in English but explain them in {request.target_language}.

Content:
{request.content[:4000]}"""
    
    contents = [{"role": "user", "parts": [{"text": prompt}]}]
    response_text = await call_gemini(contents, temperature=0.2)
    
    return {"translated": response_text, "target_language": request.target_language}


# ── OCR Explain ───────────────────────────────────────────────────────────────

@app.post("/api/ocr/explain")
async def explain_ocr(request: OCRRequest):
    """Explain extracted text from textbook image."""
    prompt = f"""A student photographed a page from their textbook. Extracted text:
"{request.extracted_text[:2000]}"

Please:
1. Explain the key concepts in simple words in {request.language}
2. Give real-life examples that an Indian student can relate to
3. List the most important points to remember
4. Create 2-3 practice questions

{f"Subject: {request.subject}" if request.subject else ""}
Keep your explanation friendly and encouraging."""
    
    contents = [{"role": "user", "parts": [{"text": prompt}]}]
    response_text = await call_gemini(contents, temperature=0.5)
    
    return {"explanation": response_text, "language": request.language}


# ── Leaderboard ───────────────────────────────────────────────────────────────

@app.get("/api/leaderboard")
async def get_leaderboard():
    """Returns sample leaderboard data (replace with Firestore in production)."""
    return {
        "leaderboard": [
            {"rank": 1, "name": "Sneha Desai", "xp": 1250, "level": 4, "streak": 15, "emoji": "🏆"},
            {"rank": 2, "name": "Aarav Sharma", "xp": 980, "level": 3, "streak": 10, "emoji": "🥈"},
            {"rank": 3, "name": "Priya Patel", "xp": 750, "level": 2, "streak": 7, "emoji": "🥉"},
            {"rank": 4, "name": "Rahul Kumar", "xp": 620, "level": 2, "streak": 5, "emoji": "⭐"},
            {"rank": 5, "name": "Ananya Singh", "xp": 480, "level": 1, "streak": 4, "emoji": "⭐"},
        ],
        "total_students": 128,
        "updated_at": datetime.utcnow().isoformat(),
    }


# ── Scholarships ──────────────────────────────────────────────────────────────

@app.get("/api/scholarships")
async def get_scholarships(category: Optional[str] = None):
    """Returns list of scholarships for Indian students."""
    scholarships = [
        {"name": "National Scholarship Portal (NSP)", "amount": "₹25,000/year", "eligibility": "SC/ST/OBC, income < 2.5L", "url": "https://scholarships.gov.in", "emoji": "🏛️"},
        {"name": "PM YASASVI Scholarship", "amount": "₹75,000/year", "eligibility": "OBC/EBC/DNT, Class 9-12", "url": "https://yet.nta.ac.in", "emoji": "🌟"},
        {"name": "SWAYAM Free Courses", "amount": "Free", "eligibility": "All students", "url": "https://swayam.gov.in", "emoji": "📖"},
        {"name": "AICTE Pragati Scholarship", "amount": "₹50,000/year", "eligibility": "Girls in technical education", "url": "https://aicte-india.org", "emoji": "👩‍🎓"},
        {"name": "Begum Hazrat Mahal Scholarship", "amount": "₹10,000-12,000/year", "eligibility": "Minority girls, Class 9-12", "url": "https://maef.net.in", "emoji": "🎓"},
        {"name": "Inspire Scholarship (DST)", "amount": "₹80,000/year", "eligibility": "Top 1% in Class 12", "url": "https://online-inspire.gov.in", "emoji": "🔬"},
    ]
    return {"scholarships": scholarships, "count": len(scholarships)}
