const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS"
};

const jsonResponse = (body: Record<string, string>, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" }
  });

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "Only POST requests are supported." }, 405);
  }

  const groqApiKey = Deno.env.get("GROQ_API_KEY");
  if (!groqApiKey) {
    return jsonResponse({ error: "The tutor is not configured yet." }, 500);
  }

  try {
    const body = await request.json();
    const question = typeof body.question === "string" ? body.question.trim() : "";
    const subject = typeof body.subject === "string" ? body.subject.trim() : "Other";
    const mode = typeof body.mode === "string" ? body.mode.trim() : "Learn";

    if (!question) {
      return jsonResponse({ error: "Please enter a question." }, 400);
    }

    if (question.length > 2000) {
      return jsonResponse({ error: "Please keep your question under 2,000 characters." }, 400);
    }

    const groqResponse = await fetch("https://api.groq.com/openai/v1/chat/completions", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${groqApiKey}`,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        model: "llama-3.3-70b-versatile",
        temperature: 0.4,
        max_tokens: 700,
        messages: [
          {
            role: "system",
            content: `You are ThinkTrail.AI, a patient educational tutor for students. The current subject is ${subject} and the current mode is ${mode}.

Guide the student toward understanding instead of doing all the work for them. Explain in clear, age-appropriate language, ask a short follow-up question when useful, and show steps for math or science problems. In Practice mode, give a similar problem before revealing an answer. In Quiz mode, ask one question at a time and wait for the student's response. Do not provide instructions for harmful, illegal, sexual, or dangerous activity. If a request is unrelated to learning, briefly redirect it to schoolwork. Do not claim to be a human or a licensed professional. Return plain text only, with no HTML.`
          },
          { role: "user", content: question }
        ]
      })
    });

    if (!groqResponse.ok) {
      return jsonResponse({ error: "Groq could not answer right now." }, 502);
    }

    const result = await groqResponse.json();
    const answer = result.choices?.[0]?.message?.content?.trim();

    if (!answer) {
      return jsonResponse({ error: "The tutor returned an empty answer." }, 502);
    }

    return jsonResponse({ answer });
  } catch {
    return jsonResponse({ error: "The tutor request was invalid." }, 400);
  }
});
