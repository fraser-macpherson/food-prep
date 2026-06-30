# Weekly Meal Plan

A simple, good-looking website for picking a meal for each day of the week, then
seeing the recipes, ingredients, and total cost for the whole week's shop.

## Files

- `index.html` — the entire site: markup, styling, and behaviour all live in this
  one file, so there are no separate CSS/JS paths that can go missing when
  uploading.
- `data/meals.json` — the list of meals offered in every day's dropdown.
- `data/recipes.json` — ingredients + a short method for each meal.
- `data/costs.json` — the price of each meal.
- `.nojekyll` — tells GitHub Pages to serve the files as-is, without running
  them through Jekyll first. Keep this file even though it looks empty.

**The meal name is the link between all three data files.** A meal in
`meals.json` only shows a recipe and a cost if the exact same name also
appears as a key in `recipes.json` and `costs.json`. If a name is missing
from one of the other files, the site still works — it just shows "No
recipe found" or "No cost found" for that meal instead of breaking.

## Editing the data

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
      "instructions": "Brown the mince, add tomatoes, simmer, serve over pasta."
    }
  }
}
```
The key (`"Spaghetti Bolognese"`) must match a name in `meals.json` exactly,
including capitalisation.

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
the `<script>` block at the bottom of `index.html`.

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
2. Upload **all four items** from this folder — `index.html`, the `data/`
   folder (with its three `.json` files inside), and `.nojekyll` — keeping
   `index.html` and `.nojekyll` at the root of the repository, and `data/`
   as a folder alongside it. If you're using GitHub's web upload, drag the
   whole `data` folder in at once rather than the files individually, so its
   folder structure is preserved.
3. In the repository, go to **Settings → Pages**.
4. Under **Build and deployment**, set **Source** to "Deploy from a branch",
   choose the branch (usually `main`) and `/ (root)` as the folder, then save.
5. GitHub will give you a URL (usually
   `https://<your-username>.github.io/<repo-name>/`) — the site is live there
   within a minute or two.
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
