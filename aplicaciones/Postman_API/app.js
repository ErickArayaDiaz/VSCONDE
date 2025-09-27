// app.js
document.getElementById("sendBtn").addEventListener("click", async () => {
  const method = document.getElementById("method").value;
  const url = document.getElementById("url").value;
  const headersText = document.getElementById("headers").value;
  const bodyText = document.getElementById("body").value;
  const responseEl = document.getElementById("response");

  // Parsear headers (cada línea key:value)
  const headers = {};
  headersText.split("\n").forEach(line => {
    const [key, value] = line.split(":").map(s => s.trim());
    if (key && value) headers[key] = value;
  });

  try {
    const options = { method, headers };
    if (method !== "GET" && bodyText.trim()) {
      options.body = bodyText;
    }

    const res = await fetch(url, options);
    const text = await res.text();

    // Intentar parsear JSON
    try {
      const json = JSON.parse(text);
      responseEl.textContent = JSON.stringify(json, null, 2);
    } catch {
      responseEl.textContent = text;
    }

  } catch (err) {
    responseEl.textContent = "Error: " + err.message;
  }
});
