<h1 id="top">Latte Logic — Coffee Trends with SQL (NTU AN6004)</h1>

<div class="meta">
  <div><strong>Course:</strong> AN6004 Data Management &amp; Visualization</div>
  <div><strong>Program:</strong> NTU MSBA</div>
  <div><strong>Author:</strong> Arif Farhan Bukhori</div>
  <div><strong>Submission artifact:</strong> 1×SQL script (<code>sql/AN6004_coffee_queries.sql</code>)</div>
</div>

<p>This repository contains SQL solutions for the <em>Latte Logic</em> assignment. The queries cover 8 tasks—from basic aggregations and window functions to a 4-table join with monthly Top-3 ranking and data-quality checks.</p>

<div class="toc">
  <strong>Contents</strong>
  <ul>
    <li><a href="#quick-start">Quick start</a></li>
    <li><a href="#structure">Repository structure</a></li>
    <li><a href="#data">Data &amp; tables referenced</a></li>
    <li><a href="#questions">What each question does</a></li>
    <li><a href="#notes">Notes, assumptions &amp; gotchas</a></li>
    <li><a href="#docker">Docker quick run (optional)</a></li>
    <li><a href="#integrity">Academic integrity</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ul>
</div>

<hr>

<h2 id="quick-start">🚀 Quick start</h2>

<h3>Requirements</h3>
<ul>
  <li><span class="badge">MySQL 8.0+</span> (window functions in Q2 &amp; Q8)</li>
  <li>Access to the course schema: <code>an6004_ia</code></li>
  <li>Optional: <span class="badge">Docker</span> (compose example below)</li>
</ul>

<h3>Run all queries</h3>
<pre><code># Using mysql CLI (adjust credentials)
mysql -h localhost -u &lt;user&gt; -p &lt; sql/AN6004_coffee_queries.sql
</code></pre>

<h3>Run a single question</h3>
<p>Open <code>sql/AN6004_coffee_queries.sql</code> and execute the relevant block in your SQL client (MySQL Workbench / DBeaver / VS Code SQLTools).</p>

<hr>

<h2 id="structure">📂 Repository structure</h2>

<pre><code>.
├── sql/
│   └── AN6004_coffee_queries.sql   # All 8 questions with inline commentary
├── assets/                         # (Optional) screenshots or notes
├── LICENSE                         # MIT
└── README.md
</code></pre>

<hr>

<h2 id="data">🧰 Data &amp; tables referenced</h2>

<p>All queries read from the course-provided schema <code>an6004_ia</code>:</p>
<ul>
  <li><code>baristacoffeesalestbl</code></li>
  <li><code>caffeine_intake_tracker</code></li>
  <li><code>coffeesales</code> <em>(includes</em> <code>coffeeID</code>, <code>shopID</code>, <code>customer_id</code><em>)</em></li>
  <li><code>consumerpreference</code></li>
  <li><code>list_coffee_shops_in_kota_bogor</code></li>
  <li><code>top-rated-coffee</code> <em>(hyphen requires backticks)</em></li>
</ul>

<p><strong>No schema changes are made</strong> — queries operate on the provided database as-is.</p>

<hr>

<h2 id="questions">✅ What each question does</h2>

<ol>
  <li><strong>Q1</strong> — Count rows per <code>product_category</code> in <code>baristacoffeesalestbl</code>.</li>
  <li><strong>Q2</strong> — Two-level breakdown: counts by (<code>customer_gender</code>, <code>loyalty_member</code>) and within each, counts by <code>is_repeat_customer</code> (window functions).</li>
  <li><strong>Q3</strong> — Sum of <code>total_amount</code> by (<code>product_category</code>, <code>customer_discovery_source</code>).
    <ul>
      <li><strong>A:</strong> Rounded presentation (display-only)</li>
      <li><strong>B:</strong> Exact totals (<em>correct for financials</em>)</li>
    </ul>
  </li>
  <li><strong>Q4</strong> — Average <code>focus_level</code> and <code>sleep_quality</code> by derived <code>time_of_day</code> and <code>gender</code> in <code>caffeine_intake_tracker</code> (handles <code>'TRUE'/'FALSE'</code> flags).</li>
  <li><strong>Q5</strong> — Identify problematic (likely duplicate) records in <code>list_coffee_shops_in_kota_bogor</code>.</li>
  <li><strong>Q6</strong> — Spending before vs. after 12:00 in <code>coffeesales</code>; excludes invalid hour values (≥24) in <code>datetime</code>.</li>
  <li><strong>Q7</strong> — Bin <code>pH</code> into 7 ranges; return means of <code>Liking</code>, <code>FlavorIntensity</code>, <code>Acidity</code>, <code>Mouthfeel</code> in <code>consumerpreference</code>.</li>
  <li><strong>Q8</strong> — 4-table join + monthly <strong>Top-3</strong> (<code>store_id</code>, <code>shopID</code>) by total spend, with:
    <ul>
      <li>backticked table names (<code>top-rated-coffee</code>)</li>
      <li>customer ID normalization (<code>CUST_1</code> → <code>1</code>)</li>
      <li><code>ROW_NUMBER()</code> ranking per month</li>
    </ul>
  </li>
</ol>

<hr>

<h2 id="notes">⚠️ Notes, assumptions &amp; gotchas</h2>
<ul>
  <li><strong>Rounding vs accuracy (Q3):</strong> Aggregate with full precision; round only at presentation time. Financial sums must remain exact.</li>
  <li><strong>Booleans as strings (Q4):</strong> Some dumps encode booleans as <code>'TRUE'/'FALSE'</code>; the <code>CASE</code> logic derives categories safely.</li>
  <li><strong>Hyphenated table name:</strong> Always wrap <code>top-rated-coffee</code> in backticks.</li>
  <li><strong>Invalid hour values (Q6):</strong> Rows where <code>HOUR(datetime) ≥ 24</code> are excluded to respect a 24-hour clock.</li>
  <li><strong>MySQL 8.0+ required:</strong> Q2/Q8 rely on <code>COUNT() OVER (...)</code> and <code>ROW_NUMBER()</code>.</li>
</ul>

<hr>

<h2 id="docker">🐳 Docker quick run (optional)</h2>

<pre><code class="language-yaml"># docker-compose.yml (example)
services:
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_ROOT_PASSWORD: root
      MYSQL_DATABASE: an6004_ia
    ports:
      - "3306:3306"
    volumes:
      - ./init:/docker-entrypoint-initdb.d
</code></pre>

<p>Place any schema/data dumps under <code>./init</code> to auto-load on startup. Then run:</p>

<pre><code>docker compose up -d
mysql -h 127.0.0.1 -u root -p &lt; sql/AN6004_coffee_queries.sql
</code></pre>

<hr>

<h2 id="integrity">📜 Academic integrity</h2>
<p>This repository contains <strong>my</strong> SQL solutions, with inline comments explaining assumptions and data issues. It does <strong>not</strong> include raw course data. Please follow your institution’s policy when referencing this work.</p>

<hr>

<h2 id="license">📄 License</h2>
<p>This project is released under the <strong>MIT License</strong> (see <code>LICENSE</code>).</p>

<hr>

<h2 id="contact">🙋‍♂️ Contact</h2>
<p><strong>Arif Farhan Bukhori</strong> — NTU MSBA ’26<br>
LinkedIn: <a href="https://www.linkedin.com/in/arifbukhori" rel="noopener noreferrer">https://www.linkedin.com/in/arifbukhori</a></p>

<p><a href="#top">Back to top ↑</a></p>

</body>
</html>
