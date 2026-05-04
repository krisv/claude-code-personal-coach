# Blog Draft Creator

Create a new blog entry for krisv.github.io blog.

## When to use

Use this skill when the user asks to:
- Create a new blog post
- Add a blog entry
- Draft a blog article
- Turn content into a blog post

## Blog Structure

- **Blog location**: `data/projects/blog/website/blog/`
- **Format**: Pure HTML (no static site generator)
- **Two types of blogs**:
  - **Standalone blogs**: Independent posts (most common)
  - **Blog series**: Multi-part series with series navigation
- **Templates**: Uses `blog-template.js` for header/footer/navigation
- **Styles**: Uses `blog-styles.css`

## Current blog entries

**Blog Series:**
- **Agentic Workforce** (3 parts): `part-1-what-is-agentic-workforce.html`, `part-2-platform-challenges.html`, `part-3-open-platform-principles.html`

**Standalone Blogs:**
- **Building Agent Stewart**: `building-agent-stewart.html`

## Standalone vs Series Blogs

**Default: Create standalone blogs** unless the user explicitly requests a series or continuation of existing series.

**Standalone blog characteristics:**
- Appears in the "Blogs" dropdown menu in header
- No series navigation below header
- Uses `initStandaloneBlog()` JavaScript function
- Naming: `topic-slug.html`

**Series blog characteristics:**
- First part appears in "Blogs" dropdown menu
- All parts have series navigation below header
- Uses `initBlogPage(N)` JavaScript function (N = part number)
- Naming: `topic-slug-part-N.html`

## How to create a STANDALONE blog (default)

1. **Read the content file** provided by the user (markdown or text)

2. **Assess content length**: 
   - If content is reasonable for one post: Create single HTML file
   - If content is very long: Ask user if they want to split into standalone posts or create a series

3. **Generate slug**: Convert title to lowercase, replace spaces with hyphens, remove special characters

4. **Convert content to HTML**:
   - If markdown: Convert headers (#, ##, ###), paragraphs, lists, code blocks, bold, italic
   - If plain text: Wrap paragraphs in `<p>` tags
   - Preserve any existing HTML

5. **Extract description**: Take first sentence or ~160 characters for SEO metadata

6. **Create HTML file** in `data/projects/blog/website/blog/` by:
   - Reading the template: `data/projects/blog/website/blog/blog-content-template.html`
   - Replacing placeholders: [TITLE], [DESCRIPTION], [SLUG], [YYYY-MM-DD], [FIRST PARAGRAPH], [CONTENT HTML]
   - The template already includes header/footer injection via `initStandaloneBlog()`

**Template structure (blog-content-template.html):**

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <!-- Google tag (gtag.js) -->
    <script async src="https://www.googletagmanager.com/gtag/js?id=G-YCMBZG48DP"></script>
    <script>
      window.dataLayer = window.dataLayer || [];
      function gtag(){dataLayer.push(arguments);}
      gtag('js', new Date());

      gtag('config', 'G-YCMBZG48DP');
    </script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[TITLE]</title>
    <meta name="description" content="[DESCRIPTION]">

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="article">
    <meta property="og:url" content="https://krisv.github.io/blog/[SLUG].html">
    <meta property="og:title" content="[TITLE]">
    <meta property="og:description" content="[DESCRIPTION]">

    <!-- Twitter -->
    <meta name="twitter:card" content="summary">
    <meta name="twitter:url" content="https://krisv.github.io/blog/[SLUG].html">
    <meta name="twitter:title" content="[TITLE]">
    <meta name="twitter:description" content="[DESCRIPTION]">

    <!-- Canonical URL -->
    <link rel="canonical" href="https://krisv.github.io/blog/[SLUG].html">

    <!-- Preconnect for performance -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link rel="preconnect" href="https://www.googletagmanager.com">

    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="blog-styles.css">

    <!-- Structured Data -->
    <script type="application/ld+json">
    {
      "@context": "https://schema.org",
      "@type": "BlogPosting",
      "headline": "[TITLE]",
      "author": {
        "@type": "Person",
        "name": "Kris Verlaenen",
        "url": "https://krisv.github.io/"
      },
      "datePublished": "[YYYY-MM-DD]",
      "dateModified": "[YYYY-MM-DD]",
      "description": "[DESCRIPTION]",
      "publisher": {
        "@type": "Person",
        "name": "Kris Verlaenen"
      },
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": "https://krisv.github.io/blog/[SLUG].html"
      }
    }
    </script>
</head>
<body>
    <section class="blog-content">
        <div class="container">
            <h1>[TITLE]</h1>

            <p class="blog-intro">[FIRST PARAGRAPH OR INTRO]</p>

[CONTENT HTML GOES HERE - headers, paragraphs, lists, etc.]

        </div>
    </section>

    <script src="blog-template.js"></script>
    <script>
        initStandaloneBlog();
    </script>
</body>
</html>
```

7. **Update header dropdown**: Edit `data/projects/blog/website/blog/blog-template.js`
   - Find the `loadHeader()` function
   - Add new entry to the "Blogs" dropdown menu within the `#blogsMenu` div
   - Example: `<a href="\${blogPrefix}building-agent-stewart.html">Building Agent Stewart</a>`
   - The `${blogPrefix}` variable automatically handles paths for both root and blog directory
   - **SINGLE SOURCE OF TRUTH:** Only update this one file! Header is reused everywhere.

8. **Report to user**:
   - Path to created blog file
   - Header dropdown updated in blog-template.js
   - Remind: Changes will be live after commit and push to GitHub

## Maintenance - Single Source of Truth

**Key principle:** Header menu is now in ONE place only!

**`data/projects/blog/website/blog/blog-template.js`**
- Single source of truth for header menu
- Used by all pages (index.html, all blog pages)
- `loadHeader(fromRoot)` function handles path prefixes automatically
- Update blog links here: `<a href="\${blogPrefix}blog-name.html">`

**When creating a new blog:**
- ✅ Use `blog-content-template.html` as starting point
- ✅ Update header in blog-template.js ONLY (one place!)
- ✅ Blog content lives inside `<section class="blog-content">` only
- ✅ Header/footer injected automatically via JavaScript

**Common mistakes to avoid:**
- ❌ Looking for header in index.html (it's dynamically injected now)
- ❌ Forgetting the `${blogPrefix}` variable in links
- ❌ Including full page structure in blog content files

## How to create a BLOG SERIES

Only create a series if:
- User explicitly asks for a multi-part series
- User is adding a new part to an existing series
- Content is too long and user confirms they want a series

For series blogs:

1. **Generate slug for series**: `topic-slug-part-N.html` (N = 1, 2, 3, etc.)

2. **Determine next part ID**: Read `blog-template.js` to find the highest `id` in the `parts` array, add 1

3. **Create HTML file** with same structure as standalone, BUT:
   - Call `initBlogPage(N)` instead of `initStandaloneBlog()` where N is the part number
   - Add previous/next navigation at the bottom:
   ```html
   <div class="next-article">
       <p>Continue reading the series</p>
       <a href="topic-slug-part-2.html">Part 2: Next Topic →</a>
   </div>
   ```

4. **Update blog-template.js**:
   - Add entry to `parts` array in `loadBlogNav()` function
   - Example: `{ id: 4, title: "Part 4: New Topic", url: "topic-slug-part-4.html" }`
   - If this is part 1 of a NEW series, also add to header dropdown

## Example: Standalone Blog

User: "Create a blog post from ai-agents-data.md with title 'AI Agents and Data Challenges'"

Actions:
1. Read `ai-agents-data.md`
2. Assess length (fits in one post, create standalone)
3. Generate slug: `ai-agents-data-challenges`
4. Convert markdown to HTML
5. Extract description from content
6. Create: `data/projects/blog/website/blog/ai-agents-data-challenges.html`
7. Update blog-template.js header dropdown: Add `<a href="ai-agents-data-challenges.html">AI Agents and Data Challenges</a>`
8. Report: Blog created, header updated, ready to commit

## Example: Series Blog

User: "Create part 4 of the Agentic Workforce series about 'Agent Coordination'"

Actions:
1. Read content
2. Generate slug: `part-4-agent-coordination.html`
3. Read blog-template.js, determine next ID is 4
4. Convert markdown to HTML
5. Create: `data/projects/blog/website/blog/part-4-agent-coordination.html` (uses `initBlogPage(4)`)
6. Update blog-template.js parts array: Add `{ id: 4, title: "Part 4: Agent Coordination", url: "part-4-agent-coordination.html" }`
7. Report: Series part created, series navigation updated, ready to commit
