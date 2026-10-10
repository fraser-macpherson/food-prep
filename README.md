# Weekly Meal Plan

A simple, good-looking website for picking a dinner, lunch, and breakfast
(each optional) for each day of the week, then seeing the recipes,
ingredients, and total cost for the whole week's shop. Vegetarian meals are
marked with a green asterisk (*) throughout, and you can add your own extra
items (like milk or bread) to the shopping list on the results page.

## Files

- `index.html` — the planner: markup, styling, and behaviour in one file.
  It also loads recipes that members added through the website and shows
  "Added by ..." on their recipe cards.
- `login.html` — member sign-in (Supabase Auth, email + password).
- `add.html` — members-only page for adding a breakfast, lunch or dinner
  (name, ingredients, method, cost, vegetarian or not). Redirects to
  `login.html` if nobody is signed in.
- `supabase-config.js` — your Supabase project URL + public key, plus the
  small shared sign-in helpers every page uses. **Edit this file first.**
- `supabase-setup.sql` — run once in the Supabase SQL Editor. Creates the
  tables, the security rules and the "who added it" tracking. Not uploaded
  to GitHub Pages (keep it in the repo or elsewhere for reference).
- `data/meals.json`, `data/recipes.json`, `data/lunch.json`,
  `data/breakfast.json` — the built-in meals, unchanged (see below).
- `.nojekyll` — tells GitHub Pages to serve the files as-is. Keep it even
  though it looks empty.

**The meal name is the link between the dinner data files.** A meal in
`meals.json` only shows a recipe and a cost if the exact same name also
appears as a key in `recipes.json`. If a name is missing from `recipes.json`,
the site still works — it just shows "No recipe found" or "No cost found"
for that meal instead of breaking. Lunch and breakfast items are
self-contained in `lunch.json` and `breakfast.json` respectively, and don't
need an entry anywhere else.

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

## Lunch and Breakfast

Each day's card only has one dropdown, for **Dinner** (one dinner meal per
day, as before). Lunch and breakfast aren't tied to a specific day —
instead, there's a **Breakfast** panel and a **Lunch** panel underneath the
day cards, each holding a free-standing list of picks for the week. Every
panel starts with two rows; use **+ Add Breakfast** / **+ Add Lunch** to add
as many more as you like, and the small `×` button on a row to remove it.
Pick a breakfast or lunch item on a row, leave it as "No meal", or delete
the row entirely — there's no day attached, so add exactly as many
breakfasts or lunches as you actually want for the week.

The lunch and breakfast items come from `data/lunch.json` and
`data/breakfast.json` respectively, and are structured just like
`data/recipes.json` — a name, ingredients, a short method, a vegetarian
flag, and a cost — so a quick sandwich or bowl of porridge gets the same
recipe card and shopping-list treatment as a full dinner.

On the results page, the dinner cards still appear one per day as before.
Any breakfasts and lunches you picked show up underneath as their own
"This week's breakfasts" / "This week's lunches" cards — each with its
ingredients and method, same as a dinner card — numbered in the order you
added them (e.g. "Breakfast 1", "Breakfast 2") since they aren't linked to
a particular day. The weekly receipt lists every pick with a "(Dinner)",
"(Lunch)", or "(Breakfast)" tag next to it, and the total adds up all three
types together. The "Combined ingredients" shopping list now pulls from
dinner, lunch, and breakfast recipes alike — an ingredient used in more
than one of them (worded identically) is combined into a single line with
a "(x2)" count, same as for repeated dinner ingredients. Click any
ingredient in that list (it strikes through on hover) to cross it off and
remove it from the list — handy for things you already have in.

You can offer as many items as you like in the Breakfast/Lunch dropdowns
(5 is just what's in the example data, not a hard limit) by adding or
removing entries in `lunch.json` or `breakfast.json` (see the format
below).

## Adding your own shopping list items

On the results page, under "Add to your shopping list" in the weekly
receipt, you can type in anything else you need to pick up — like milk,
bread, or snacks — with an optional cost, and it's added to the list and
(if you gave it a cost) folded into the weekly total. Use the small `×`
button next to an item to remove it.

The "Combined ingredients" list above it works a little differently, since
those lines come from recipes rather than being typed in: click directly on
an ingredient to cross it off and remove it (it shows a strikethrough as
you hover, as a preview before you click). This doesn't affect the weekly
total, since ingredients don't carry their own cost — it's just there to
help you tick off things you already have.

These are session-only: they exist just in your browser for the week you're
currently planning, aren't saved anywhere, and reset whenever you plan a new
week. They're for quick additions on the fly, not for changing what's
offered in the dropdowns — for that, edit `lunch.json` or `breakfast.json`,
or sign in and use the Add recipe page instead.

## Accounts and member recipes (Supabase)

### How it fits together

- **Reading is public.** Anyone visiting the site sees the built-in JSON
  meals *and* every recipe members have added. Member recipes appear in the
  same dropdowns, recipe cards, receipt and shopping list as built-in ones.
- **Writing needs an account.** Only signed-in users can add recipes, and
  only as themselves. Users can delete their own recipes but nobody else's.
  These rules are enforced by the database (Row Level Security), not just by
  the page, so they hold even if someone pokes at the site's code.
- **Who added what.** Each recipe row stores the adding user's id
  automatically. The planner shows "Added by <name>" on recipe cards, and the
  Add recipe page lists every member recipe with its author and date.
- **Built-in meals stay in JSON** and show no "Added by" line. If a member
  adds a recipe with the same name as a built-in one of the same type, it's
  listed as "Name (by Sam)" so both are kept.

### One-time setup

1. **Supabase project.** Use an existing project or create one at
   supabase.com. Tables are prefixed `meal_` so they won't clash with another
   app (such as an asset tracker) in the same project.
2. **Run the SQL.** Dashboard → SQL Editor → New query → paste the contents of
   `supabase-setup.sql` → Run. It's safe to run again.
3. **Turn off public sign-ups.** Dashboard → Authentication → Sign In /
   Providers (older dashboards: Settings) → switch off **Allow new users to
   sign up**. This matters: the public key is visible in the site's code, so
   with sign-ups on, anyone could create an account and add recipes.
4. **Add your users.** Dashboard → Authentication → Users → Add user →
   Create new user. Enter email + password and tick **Auto Confirm User** so
   they can sign in straight away. A profile row is created automatically.
   To control the name shown as "Added by", open the user's metadata (or
   create them with user metadata `{"display_name": "Sam"}`); otherwise it
   defaults to the part of their email before the `@`, which is visible to
   all visitors.
5. **Connect the site.** Dashboard → Project Settings → API (or "API Keys").
   Copy the **Project URL** and the **anon / publishable** key into
   `supabase-config.js`. Never use the `service_role` / secret key there.
6. **Upload** `index.html`, `login.html`, `add.html`, `supabase-config.js`,
   the `data/` folder and `.nojekyll` to GitHub Pages as before.
7. **Allow your site's address.** Dashboard → Authentication → URL
   Configuration → set Site URL to your GitHub Pages address. (Only needed
   for email links like password resets, but good practice.)

### Day to day

- **Members:** open **Sign in**, then **Add recipe** appears in the nav bar.
  Pick Breakfast / Lunch / Dinner, fill in the form, and the recipe is live
  immediately for everyone.
- **You (the owner):**
  - Add or remove users in Authentication → Users.
  - See who added what: SQL Editor →
    `select * from public.meal_recipes_admin;` (includes emails; this view
    is blocked from the website's roles so emails are never exposed).
  - Remove a bad recipe: Table Editor → `meal_recipes` → delete the row.
  - Rename someone's "Added by": see the SQL comment at the bottom of
    `supabase-setup.sql`.

### Good to know

- Passwords are handled entirely by Supabase Auth; the site never stores them.
- Sessions persist in the browser, so members stay signed in until they click
  **Sign out**.
- Recipes can be added and deleted from the site but not edited; to fix a
  typo, delete and re-add it (or edit the row in the Table Editor).
- The old password-gated "request" flow and the `PASSWORD_HASH` have been
  removed.

## Editing the data directly

All the data files are plain JSON, so they can be edited directly on GitHub
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
appear in the dinner dropdown.

### `data/recipes.json`
```json
{
  "currency": "GBP",
  "recipes": {
    "Spaghetti Bolognese": {
      "ingredients": ["250g spaghetti", "400g beef mince"],
      "instructions": "Brown the mince, add tomatoes, simmer, serve over pasta.",
      "vegetarian": false,
      "cost": 4.80
    }
  }
}
```
The key (`"Spaghetti Bolognese"`) must match a name in `meals.json` exactly,
including capitalisation. Set `"vegetarian"` to `true` to show the green
asterisk marker next to that meal around the site, or `false` (or leave it
out) if it isn't vegetarian. `"cost"` is a plain number, no currency symbol.
The top-level `"currency"` field controls which symbol is shown for prices
everywhere on the site, including breakfast/lunch items — use `GBP`, `USD`,
or `EUR`.

### `data/lunch.json`
```json
{
  "items": {
    "Ham & Cheese Sandwich": {
      "ingredients": ["2 slices bread", "2 slices ham", "1 slice cheddar"],
      "instructions": "Butter the bread, layer the ham and cheese, and slice in half.",
      "vegetarian": false,
      "cost": 2.20
    }
  }
}
```
Each key is the item name shown in the Lunch dropdown. `"ingredients"`,
`"instructions"`, `"cost"`, and `"vegetarian"` all work exactly the same as
in `recipes.json` — ingredients are combined into the shopping list on the
results page, and the instructions show on that item's recipe card. Add,
remove, or rename entries freely; there's no separate list to keep in
sync, unlike dinner meals.

### `data/breakfast.json`
```json
{
  "items": {
    "Porridge with Berries": {
      "ingredients": ["50g porridge oats", "200ml milk", "Handful mixed berries"],
      "instructions": "Simmer oats in milk for 5 mins, stirring often. Top with berries.",
      "vegetarian": true,
      "cost": 1.50
    }
  }
}
```
Same format as `lunch.json`, but for the items shown in the Breakfast
dropdown. Add, remove, or rename entries freely.

If you ever want to change the look of the page or the dropdown/results
behaviour, the styling lives in the `<style>` block and the logic lives in
the `<script>` block at the bottom of `index.html`. `add.html` and
`login.html` have their own matching `<style>` blocks — if you change the
look of one page, update the others to match.

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

1. Complete the Supabase setup above.
2. Create a new GitHub repository.
3. Upload `index.html`, `login.html`, `add.html`, `supabase-config.js`, the
   `data/` folder (with its four `.json` files) and `.nojekyll`, all at the
   root. If you're using GitHub's web upload, drag the whole `data` folder
   in at once so its structure is preserved.
4. Settings → Pages → Source "Deploy from a branch", choose `main` and
   `/ (root)`, then save.
5. The site is live at `https://<your-username>.github.io/<repo-name>/`
   within a minute or two.
6. Built-in meals: edit `data/*.json` and commit. Member recipes need no
   commit — they're stored in Supabase.

## Notes on behaviour

- A day left as "No meal" for dinner is skipped in the results and shopping
  list (its card just says so). An empty or "No meal" row in the Breakfast
  or Lunch panel is likewise skipped — it doesn't add a blank entry to the
  results or receipt.
- If the same dinner is picked for two different days, or the same
  breakfast/lunch item is picked on two different rows, it's listed twice
  and its cost is counted twice in the weekly total (it's two separate
  things to cook or buy for).
- Ingredients spelled identically across any dinner, lunch, or breakfast
  recipe are combined into a single line with a "(x2)" count in the
  shopping list; ingredients written slightly differently (e.g. "1 onion"
  vs "1 onion, diced") are listed separately, since the site matches
  ingredient text exactly.
- Extra shopping list items you add on the results page are per-session:
  they're not saved anywhere and reset the next time you click "Plan my
  week".
