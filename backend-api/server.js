const express = require("express");
const app = express();
const PORT = 5000; // or any port

app.get("/", (req, res) => {
  res.send("Server is running");
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
