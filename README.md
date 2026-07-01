# Weekly Meal Plan

A simple, good-looking website for picking a meal for each day of the week, then
seeing the recipes, ingredients, and total cost for the whole week's shop.
Vegetarian meals are marked with a green asterisk (*) throughout.

## Files

- `index.html` — the planner: markup, styling, and behaviour all live in this
  one file, so there are no separate CSS/JS paths that can go missing when
  uploading.
- `add.html` — a password-gated page for putting together a request for a
  new meal (recipe + ingredients + cost + vegetarian or not) without
  hand-editing the JSON files. Also fully self-contained.
- `data/meals.json` — the list of meals offered in every day's dropdown.
- `data/recipes.json` — ingredients, a short method, and a vegetarian
  true/false flag for each meal.
- `data/costs.json` — the price of each meal.
- `.nojekyll` — tells GitHub Pages to serve the files as-is, without running
  them through Jekyll first. Keep this file even though it looks empty.

**The meal name is the link between all three data files.** A meal in
`meals.json` only shows a recipe and a cost if the exact same name also
appears as a key in `recipes.json` and `costs.json`. If a name is missing
from one of the other files, the site still works — it just shows "No
recipe found" or "No cost found" for that meal instead of breaking.

## Vegetarian marker

Any meal can be flagged as vegetarian by setting `"vegetarian": true` on its
entry in `data/recipes.json` (see the format below). Where this is `true`,
the site shows a green asterisk (`*`) next to the meal name:

- In each day's dropdown on the planner (shown as plain text there, since
  browsers don't reliably support colouring inside dropdown lists — but the
  meal name itself is tinted green where the browser allows it).
- On the meal name in each day's recipe card after you plan the week.
- Next to the meal in the "Meals" list on the weekly shop receipt.
- Next to the meal name in the "In this request so far" list on the Add
  options page.

A short legend ("* Vegetarian meal") sits under the heading on the planner
page as a key. Meals with no `vegetarian` field, or with it set to `false`,
are treated as non-vegetarian and shown with no marker — nothing breaks if
the field is left out of an older entry.

## Requesting new meals through the website

`add.html` (linked from the nav bar and footer as **Add options**) gives you
a form for putting together a request for a new meal — its recipe,
ingredients, cost, and whether it's vegetarian — with built-in validation:

- **Shared password** — required, and masked as you type. The page checks it
  against a stored hash rather than a plain-text value.
- **Meal name** — required, and checked against the meals already loaded so
  you can't accidentally create a duplicate.
- **Ingredients** — add as many rows as you need; at least one non-empty
  ingredient is required.
- **Method** — required.
- **Cost** — required, must be a number greater than 0.
- **Vegetarian** — an optional checkbox; leave it unchecked if the meal isn't
  vegetarian.

After a successful submit, the page shows the fully updated contents of
`meals.json`, `recipes.json`, and `costs.json` (the existing data plus the
new meal, correctly cross-linked across all three, including the vegetarian
flag). Copy or download each part and send it to whoever manages the site so
they can add it — the page itself only prepares the request, it doesn't
publish anything on its own. You can add several meals to one request before
sending anything — each addition builds on the last within that browser
session.

### Why requests aren't published automatically

This is a note for whoever maintains the site — it's deliberately left off
the page itself to keep things simple for anyone filling in a request.
GitHub Pages only serves static files; it can't run server code or write to
your repository. That's why `add.html` can only prepare a correctly
formatted request rather than publish it — you (or whoever has repo access)
still need to take the copied or downloaded JSON and commit it to `data/` to
make a requested meal live.

### About the password

Because this is a public static site, there's no real backend to enforce
permissions — anyone who looks at the page's source could, in principle,
find a way to bypass a client-side check. Hashing the password (instead of
storing it as plain text) stops it being casually visible in the page
source, but **treat this as a basic deterrent, not real security.** Don't
use a password you use anywhere else, and don't rely on this to protect
anything sensitive.

The default password is `mealprep2026`. To change it:

1. Open `add.html` in a browser.
2. Open the browser's developer console (e.g. F12, or right-click →
   Inspect → Console).
3. Run:
   ```js
   crypto.subtle.digest('SHA-256', new TextEncoder().encode('yourNewPassword'))
     .then(b => console.log(Array.from(new Uint8Array(b))
       .map(x => x.toString(16).padStart(2, '0')).join('')))
   ```
4. Copy the hash that gets printed.
5. In `add.html`, find the line starting `const PASSWORD_HASH = ` near the
   top of the `<script>` block, and replace the value with your new hash.
6. Commit the updated `add.html`.

## Editing the data directly

All three data files are plain JSON, so they can be edited directly on GitHub
(open the file → pencil icon → edit → commit) or in any text editor. No code
changes are needed — the dropdowns and results update automatically next
time the page loads.

### `data/meals.json`
```json
{
  "meals": [
    "Spaghetti Bolognese",
    "Chicken Curry"
  ]
}
```
Add or remove names from the `meals` array. Order here is the order they'll
appear in each dropdown.

### `data/recipes.json`
```json
{
  "recipes": {
    "Spaghetti Bolognese": {
      "ingredients": ["250g spaghetti", "400g beef mince"],
      "instructions": "Brown the mince, add tomatoes, simmer, serve over pasta.",
      "vegetarian": false
    }
  }
}
```
The key (`"Spaghetti Bolognese"`) must match a name in `meals.json` exactly,
including capitalisation. Set `"vegetarian"` to `true` to show the green
asterisk marker next to that meal around the site, or `false` (or leave it
out) if it isn't vegetarian.

### `data/costs.json`
```json
{
  "currency": "GBP",
  "costs": {
    "Spaghetti Bolognese": 4.80
  }
}
```
Costs are plain numbers (no currency symbol). `currency` controls the symbol
shown on the page — use `GBP`, `USD`, or `EUR`.

If you ever want to change the look of the page or the dropdown/results
behaviour, the styling lives in the `<style>` block and the logic lives in
the `<script>` block at the bottom of `index.html`. `add.html` has its own
matching `<style>` and `<script>` blocks — if you change the look of one
page, update the other to match.

## Important: this must be served over http://, not opened as a file

Because the page loads the JSON files with `fetch()`, your browser needs to
load it via a web address (`http://...` or `https://...`), not by
double-clicking `index.html` and opening it as a local `file://` path.
Browsers block that kind of local file loading for security reasons, and the
day dropdowns will appear empty if you try it.

To test on your own computer, run this from the project folder:

```bash
python3 -m http.server 8000
```

then open `http://localhost:8000` in your browser. GitHub Pages serves the
site correctly automatically, so once it's published this isn't a concern.

## Publishing on GitHub Pages

1. Create a new GitHub repository.
2. Upload **all five items** from this folder — `index.html`, `add.html`,
   the `data/` folder (with its three `.json` files inside), and
   `.nojekyll` — keeping `index.html`, `add.html`, and `.nojekyll` at the
   root of the repository, and `data/` as a folder alongside them. If you're
   using GitHub's web upload, drag the whole `data` folder in at once rather
   than the files individually, so its folder structure is preserved.
3. In the repository, go to **Settings → Pages**.
4. Under **Build and deployment**, set **Source** to "Deploy from a branch",
   choose the branch (usually `main`) and `/ (root)` as the folder, then save.
5. GitHub will give you a URL (usually
   `https://<your-username>.github.io/<repo-name>/`) — the site is live there
   within a minute or two, with the planner at that address and the add page
   at the same address plus `add.html`.
6. From then on, editing any of the three `data/*.json` files in the repo and
   committing the change is all it takes to update the live site — no
   rebuild step required.

## Notes on behaviour

- Days left as "No meal" are skipped in the results and shopping list.
- If the same meal is picked for two different days, it's listed twice in
  the daily breakdown, and its cost is counted twice in the weekly total
  (it's two separate meals to cook and buy for).
- Ingredients spelled identically in two recipes are combined into a single
  line with a "(x2)" count in the shopping list; ingredients written
  slightly differently (e.g. "1 onion" vs "1 onion, diced") are listed
  separately, since the site matches ingredient text exactly.
