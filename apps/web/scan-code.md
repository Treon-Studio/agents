# Astro Cactus - Scan Code Report

## Tech Stacks

| Category | Technology |
|----------|------------|
| **Framework** | Astro 6.0.4 |
| **Styling** | TailwindCSS 4, CSSnano |
| **Language** | TypeScript |
| **Markdown/MDX** | @astrojs/mdx, unified, remark-directive |
| **UI Features** | astro-expressive-code, astro-icon, astro-webmanifest |
| **SEO** | astro-robots-txt, @astrojs/sitemap |
| **Image** | sharp, satori, satori-html |
| **Search** | pagefind |
| **Icons** | @iconify-json/mdi |
| **Linting** | Biome 2, Prettier |

## Package Structure

```
web/
├── astro.config.ts          # Astro configuration with integrations
├── tailwind.config.ts       # TailwindCSS 4 configuration
├── package.json             # Dependencies
├── src/
│   ├── assets/              # Static assets
│   ├── components/          # Astro components
│   │   ├── blog/            # Blog-specific components
│   │   │   ├── Masthead.astro
│   │   │   ├── PostPreview.astro
│   │   │   ├── TOC.astro
│   │   │   ├── TOCHeading.astro
│   │   │   └── webmentions/  # Webmentions components
│   │   │       ├── Comments.astro
│   │   │       ├── Likes.astro
│   │   │       └── index.astro
│   │   ├── layout/           # Layout components
│   │   │   ├── Footer.astro
│   │   │   └── Header.astro
│   │   ├── note/             # Note components
│   │   │   └── Note.astro
│   │   ├── BaseHead.astro
│   │   ├── FormattedDate.astro
│   │   ├── Paginator.astro
│   │   ├── Search.astro
│   │   ├── SkipLink.astro
│   │   ├── SocialList.astro
│   │   ├── ThemeProvider.astro
│   │   └── ThemeToggle.astro
│   ├── content/              # Content collections (posts, notes)
│   ├── data/                 # Data files
│   ├── layouts/              # Page layouts
│   │   ├── Base.astro
│   │   └── BlogPost.astro
│   ├── pages/                # Routes
│   ├── plugins/              # Custom remark/rehype plugins
│   ├── styles/               # CSS files
│   ├── site.config.ts        # Site configuration
│   ├── content.config.ts     # Content collections config
│   └── utils/                # Utility functions
├── public/                   # Static public files
└── biomes.json               # Linter config
```

---

## Components Detail

### 1. BaseHead.astro

Meta tags, Open Graph, Twitter cards, sitemap, RSS.

```astro
---
import { WEBMENTION_PINGBACK, WEBMENTION_URL } from "astro:env/client";
import { siteConfig } from "@/site.config";
import type { SiteMeta } from "@/types";
import "@/styles/global.css";

type Props = SiteMeta;

const { articleDate, description, ogImage, title } = Astro.props;

const titleSeparator = "•";
const siteTitle = `${title} ${titleSeparator} ${siteConfig.title}`;
const canonicalURL = new URL(Astro.url.pathname, Astro.site);
const socialImageURL = new URL(ogImage ? ogImage : "/social-card.png", Astro.url).href;
---

<meta charset="utf-8" />
<meta content="width=device-width, initial-scale=1.0" name="viewport" />
<title>{siteTitle}</title>

{/* Icons */}
<link href="/icon.svg" rel="icon" type="image/svg+xml" />
{
  import.meta.env.PROD && (
    <>
      <link rel="icon" href="/favicon-32x32.png" type="image/png" />
      <link href="/icons/apple-touch-icon.png" rel="apple-touch-icon" />
      <link href="/manifest.webmanifest" rel="manifest" />
    </>
  )
}

{/* Canonical URL */}
<link href={canonicalURL} rel="canonical" />

{/* Primary Meta Tags */}
<meta content={siteTitle} name="title" />
<meta content={description} name="description" />
<meta content={siteConfig.author} name="author" />

{/* Open Graph / Facebook */}
<meta content={articleDate ? "article" : "website"} property="og:type" />
<meta content={title} property="og:title" />
<meta content={description} property="og:description" />
<meta content={canonicalURL} property="og:url" />
<meta content={siteConfig.title} property="og:site_name" />
<meta content={siteConfig.ogLocale} property="og:locale" />
<meta content={socialImageURL} property="og:image" />
<meta content="1200" property="og:image:width" />
<meta content="630" property="og:image:height" />

{/* Twitter */}
<meta content="summary_large_image" property="twitter:card" />
<meta content={canonicalURL} property="twitter:url" />
<meta content={title} property="twitter:title" />
<meta content={description} property="twitter:description" />
<meta content={socialImageURL} property="twitter:image" />

{/* RSS auto-discovery */}
<link href="/rss.xml" title="Blog" rel="alternate" type="application/rss+xml" />
<link href="/notes/rss.xml" title="Notes" rel="alternate" type="application/rss+xml" />
```

---

### 2. Footer.astro

Site footer with copyright and navigation links.

```astro
---
import { menuLinks, siteConfig } from "@/site.config";

const year = new Date().getFullYear();
---

<footer
  class="text-muted mt-auto flex w-full flex-col items-center justify-center gap-y-2 pt-20 pb-4 text-center align-top font-semibold sm:flex-row sm:justify-between sm:text-xs"
>
  <div class="me-0 sm:me-4">
    &copy; {siteConfig.author}
    {year}.<span class="inline-block">&nbsp;🚀&nbsp;{siteConfig.title}&nbsp;🌵&nbsp;</span>
  </div>
  <nav aria-labelledby="footer_links" class="sm:divide-muted flex gap-x-2 sm:gap-x-0 sm:divide-x">
    <p id="footer_links" class="sr-only">More on this site</p>
    {
      menuLinks.map((link) => (
        <a class="hover:text-global-text px-4 py-2 hover:underline sm:py-0" href={link.path}>
          {link.title}
        </a>
      ))
    }
  </nav>
</footer>
```

---

### 3. Header.astro

Site header with logo, navigation, search, and theme toggle.

```astro
---
import Search from "@/components/Search.astro";
import ThemeToggle from "@/components/ThemeToggle.astro";
import { menuLinks } from "@/site.config";
import { siteConfig } from "../../site.config";
---

<header class="group relative mb-28 flex items-center sm:ps-18" id="main-header">
  <div class="flex sm:flex-col">
    <a
      aria-current={Astro.url.pathname === "/" ? "page" : false}
      class="inline-flex items-center sm:relative sm:inline-block sm:grayscale sm:hover:filter-none"
      href="/"
    >
      <svg aria-hidden="true" class="me-3 h-10 w-6 sm:absolute sm:-start-18 sm:me-0 sm:h-20 sm:w-12" ...>
        <title>Astro Cactus Logo</title>
        <!-- Logo paths -->
      </svg>
      <span class="text-xl font-bold sm:text-2xl">{siteConfig.title}</span>
    </a>
    <nav aria-label="Main menu" class="..." id="navigation-menu">
      {
        menuLinks.map((link) => (
          <a
            aria-current={Astro.url.pathname === link.path ? "page" : false}
            class="text-accent px-2 py-4 font-semibold sm:px-4 sm:py-0 sm:underline-offset-2 sm:hover:underline"
            href={link.path}
          >
            {link.title}
          </a>
        ))
      }
    </nav>
  </div>
  <Search />
  <ThemeToggle />
  <mobile-button>
    <button aria-expanded="false" ...>
      <span class="sr-only">Open main menu</span>
      <!-- Hamburger/Cross icons -->
    </button>
  </mobile-button>
</header>

<script>
  import { toggleClass } from "@/utils/domElement";

  class MobileNavBtn extends HTMLElement {
    #menuOpen: boolean = false;

    connectedCallback() {
      const headerEl = document.getElementById("main-header")!;
      const mobileButtonEl = this.querySelector<HTMLButtonElement>("button");

      mobileButtonEl?.addEventListener("click", () => {
        if (headerEl) toggleClass(headerEl, "menu-open");
        this.#menuOpen = !this.#menuOpen;
        mobileButtonEl.setAttribute("aria-expanded", this.#menuOpen.toString());
      });
    }
  }

  customElements.define("mobile-button", MobileNavBtn);
</script>
```

---

### 4. ThemeProvider.astro

Handles theme initialization (light/dark) to prevent FOUC.

```astro
{/* Inlined to avoid FOUC. This is a parser blocking script. */}
<script is:inline>
  const lightModePref = window.matchMedia("(prefers-color-scheme: light)");

  function getUserPref() {
    const storedTheme = typeof localStorage !== "undefined" && localStorage.getItem("theme");
    return storedTheme || (lightModePref.matches ? "light" : "dark");
  }

  function setTheme(newTheme) {
    if (newTheme !== "light" && newTheme !== "dark") {
      return console.warn(`Invalid theme value '${newTheme}' received.`);
    }

    const root = document.documentElement;

    if (newTheme === root.getAttribute("data-theme")) {
      return;
    }

    root.setAttribute("data-theme", newTheme);

    if (typeof localStorage !== "undefined") {
      localStorage.setItem("theme", newTheme);
    }
  }

  // initial setup
  setTheme(getUserPref());

  // listen for theme-change custom event
  document.addEventListener("theme-change", (e) => {
    setTheme(e.detail.theme);
  });

  // listen for prefers-color-scheme change
  lightModePref.addEventListener("change", (e) => setTheme(e.matches ? "light" : "dark"));
</script>
```

---

### 5. ThemeToggle.astro

Dark/light theme toggle button.

```astro
<theme-toggle class="ms-2 sm:ms-4">
  <button class="hover:text-accent relative h-9 w-9 cursor-pointer rounded-md p-2" type="button">
    <span class="sr-only">Dark Theme</span>
    <!-- Sun SVG (light mode) -->
    <svg id="sun-svg" ...>...</svg>
    <!-- Moon SVG (dark mode) -->
    <svg id="moon-svg" ...>...</svg>
  </button>
</theme-toggle>

<script>
  import { rootInDarkMode } from "@/utils/domElement";

  class ThemeToggle extends HTMLElement {
    constructor() {
      super();
      const button = this.querySelector<HTMLButtonElement>("button");

      if (button) {
        button.setAttribute("role", "switch");
        button.setAttribute("aria-checked", String(rootInDarkMode()));

        button.addEventListener("click", () => {
          let themeChangeEvent = new CustomEvent("theme-change", {
            detail: { theme: rootInDarkMode() ? "light" : "dark" },
          });
          document.dispatchEvent(themeChangeEvent);
          button.setAttribute("aria-checked", String(rootInDarkMode()));
        });
      }
    }
  }

  customElements.define("theme-toggle", ThemeToggle);
</script>
```

---

### 6. Search.astro

Site search using Pagefind with keyboard shortcut (Ctrl+K / Cmd+K).

```astro
---
import "@/styles/blocks/search.css";
---

<site-search class="ms-auto" id="search">
  <button
    class="hover:text-accent flex h-9 w-9 cursor-pointer items-center justify-center rounded-md"
    aria-keyshortcuts="Control+K Meta+K"
    data-open-modal
    disabled
  >
    <svg ...><path d="M3 10a7 7 0 1 0 14 0 7 7 0 1 0-14 0M21 21l-6-6"></path></svg>
    <span class="sr-only">Open Search</span>
  </button>
  <dialog ...>
    <div class="dialog-frame flex grow flex-col gap-4 p-6 pt-12 ...">
      <button data-close-modal>Close</button>
      {
        import.meta.env.DEV ? (
          <div>Search only available in production builds</div>
        ) : (
          <div class="search-container">
            <div id="cactus__search" />
          </div>
        )
      }
    </div>
  </dialog>
</site-search>

<script>
  class SiteSearch extends HTMLElement {
    #openBtn: HTMLButtonElement | null;
    #closeBtn: HTMLButtonElement | null;
    #dialog: HTMLDialogElement | null;
    #controller: AbortController;

    constructor() {
      super();
      // Setup event listeners
      if (import.meta.env.DEV) return;

      const onIdle = window.requestIdleCallback || ((cb) => setTimeout(cb, 1));
      onIdle(async () => {
        const { PagefindUI } = await import("@pagefind/default-ui");
        new PagefindUI({
          baseUrl: import.meta.env.BASE_URL,
          bundlePath: import.meta.env.BASE_URL.replace(/\/$/, "") + "/pagefind/",
          element: "#cactus__search",
          showImages: false,
          showSubResults: true,
        });
      });
    }

    // ... keyboard shortcuts, modal open/close

    onWindowKeydown = (e: KeyboardEvent) => {
      if ((e.metaKey === true || e.ctrlKey === true) && e.key === "k") {
        this.#dialog.open ? this.closeModal() : this.openModal();
        e.preventDefault();
      }
    };
  }

  customElements.define("site-search", SiteSearch);
</script>
```

---

### 7. FormattedDate.astro

Formatted date display using locale options.

```astro
---
import type { HTMLAttributes } from "astro/types";
import { getFormattedDate } from "@/utils/date";

type Props = HTMLAttributes<"time"> & {
  date: Date;
  dateTimeOptions?: Intl.DateTimeFormatOptions;
};

const { date, dateTimeOptions, ...attrs } = Astro.props;

const postDate = getFormattedDate(date, dateTimeOptions);
const ISO = date.toISOString();
---

<time datetime={ISO} title={ISO} {...attrs}>{postDate}</time>
```

---

### 8. SkipLink.astro

Accessibility skip link.

```astro
<a class="sr-only focus:not-sr-only focus:fixed focus:start-1 focus:top-1.5" href="#main">
  skip to content
</a>
```

---

### 9. SocialList.astro

Social media links with icons.

```astro
---
import { Icon } from "astro-icon/components";

const socialLinks: {
  friendlyName: string;
  isWebmention?: boolean;
  link: string;
  name: string;
}[] = [
  { friendlyName: "Github", link: "https://github.com/...", name: "mdi:github" },
];

<div class="flex flex-wrap items-end gap-x-2">
  <p>Find me on</p>
  <ul class="flex flex-1 items-center gap-x-2 sm:flex-initial">
    {
      socialLinks.map(({ friendlyName, isWebmention, link, name }) => (
        <li class="flex">
          <a class="hover:text-link inline-block" href={link} rel={`noreferrer ${isWebmention ? "me authn" : ""}`} target="_blank">
            <Icon aria-hidden="true" class="h-8 w-8" focusable="false" name={name} />
            <span class="sr-only">{friendlyName}</span>
          </a>
        </li>
      ))
    }
  </ul>
</div>
```

---

### 10. Paginator.astro

Previous/Next page navigation.

```astro
---
import type { PaginationLink } from "@/types";

interface Props {
  nextUrl?: PaginationLink;
  prevUrl?: PaginationLink;
}

const { nextUrl, prevUrl } = Astro.props;
---

{
  (prevUrl || nextUrl) && (
    <nav class="mt-8 flex items-center gap-x-4">
      {prevUrl && (
        <a class="hover:text-accent me-auto py-2" href={prevUrl.url}>
          {prevUrl.srLabel && <span class="sr-only">{prevUrl.srLabel}</span>}
          {prevUrl.text ? prevUrl.text : "Previous"}
        </a>
      )}
      {nextUrl && (
        <a class="hover:text-accent ms-auto py-2" href={nextUrl.url}>
          {nextUrl.srLabel && <span class="sr-only">{nextUrl.srLabel}</span>}
          {nextUrl.text ? nextUrl.text : "Next"}
        </a>
      )}
    </nav>
  )
}
```

---

### 11. Blog Components

#### Masthead.astro

Post header with cover image, title, date, reading time, and tags.

```astro
---
import { Image } from "astro:assets";
import type { CollectionEntry } from "astro:content";
import FormattedDate from "@/components/FormattedDate.astro";

interface Props {
  content: CollectionEntry<"post">;
  readingTime: string;
}

const { content: { data }, readingTime } = Astro.props;

const dateTimeOptions: Intl.DateTimeFormatOptions = { month: "long" };
---

{
  data.coverImage && (
    <div class="mb-6 aspect-video">
      <Image alt={data.coverImage.alt} layout="constrained" width={748} height={420} priority src={data.coverImage.src} />
    </div>
  )
}
{data.draft ? <span class="text-base text-red-500">(Draft)</span> : null}
<h1 class="title">{data.title}</h1>
<div class="flex flex-wrap items-center gap-x-3 gap-y-2">
  <p class="font-semibold">
    <FormattedDate date={data.publishDate} dateTimeOptions={dateTimeOptions} /> / {readingTime}
  </p>
  {
    data.updatedDate && (
      <span class="bg-quote/5 text-quote rounded-lg px-2 py-1">
        Updated: <FormattedDate class="ms-1" date={data.updatedDate} dateTimeOptions={dateTimeOptions} />
      </span>
    )
  }
</div>
{!!data.tags?.length && (
  <div class="mt-2">
    <!-- Tags with # prefix -->
  </div>
)}
```

#### PostPreview.astro

Preview card for post listings (polymorphic component).

```astro
---
import type { CollectionEntry } from "astro:content";
import type { HTMLTag, Polymorphic } from "astro/types";
import FormattedDate from "@/components/FormattedDate.astro";

type Props<Tag extends HTMLTag> = Polymorphic<{ as: Tag }> & {
  post: CollectionEntry<"post">;
  withDesc?: boolean;
};

const { as: Tag = "div", post, withDesc = false } = Astro.props;
---

<FormattedDate class="text-muted min-w-30 font-semibold" date={post.data.publishDate} />
<Tag>
  {post.data.draft && <span class="text-red-500">(Draft) </span>}
  <a class="cactus-link" href={`/posts/${post.id}/`}>{post.data.title}</a>
</Tag>
{withDesc && <q class="line-clamp-3 italic">{post.data.description}</q>}
```

#### TOC.astro

Table of Contents for blog posts.

```astro
---
import type { MarkdownHeading } from "astro";
import { generateToc } from "@/utils/generateToc";
import TOCHeading from "./TOCHeading.astro";

interface Props {
  headings: MarkdownHeading[];
}

const { headings } = Astro.props;
const toc = generateToc(headings);
---

<details open class="lg:sticky lg:top-12 lg:order-2 lg:-me-32 lg:basis-64">
  <summary class="title hover:marker:text-accent cursor-pointer text-lg">Table of Contents</summary>
  <nav class="ms-4 lg:w-full">
    <ol class="mt-4">
      {toc.map((heading) => <TOCHeading heading={heading} />)}
    </ol>
  </nav>
</details>
```

#### TOCHeading.astro

Recursive TOC heading item.

```astro
---
import type { TocItem } from "@/utils/generateToc";

interface Props {
  heading: TocItem;
}

const { heading: { children, depth, slug, text } } = Astro.props;
---

<li class={`${depth > 2 ? "ms-2" : ""}`}>
  <a class={`line-clamp-2 hover:text-accent ${depth <= 2 ? "mt-3" : "mt-2 text-xs"}`} href={`#${slug}`}>
    <span aria-hidden="true" class="me-0.5">#</span>{text}
  </a>
  {
    !!children.length && (
      <ol>
        {children.map((subheading) => (
          <Astro.self heading={subheading} />
        ))}
      </ol>
    )
  }
</li>
```

---

### 12. Note Components

#### Note.astro

Note article component (polymorphic).

```astro
---
import { type CollectionEntry, render } from "astro:content";
import type { HTMLTag, Polymorphic } from "astro/types";
import FormattedDate from "@/components/FormattedDate.astro";

type Props<Tag extends HTMLTag> = Polymorphic<{ as: Tag }> & {
  note: CollectionEntry<"note">;
  isPreview?: boolean | undefined;
};

const { as: Tag = "div", note, isPreview = false } = Astro.props;
const { Content } = await render(note);
---

<article class:list={[isPreview && "bg-global-text/5 inline-grid rounded-md px-4 py-3"]} data-pagefind-body={isPreview ? false : true}>
  <Tag class="title" class:list={{ "text-base": isPreview }}>
    {
      isPreview ? (
        <a class="cactus-link" href={`/notes/${note.id}/`}>{note.data.title}</a>
      ) : (
        <>{note.data.title}</>
      )
    }
  </Tag>
  <FormattedDate dateTimeOptions={{ hour: "2-digit", minute: "2-digit", year: "2-digit", month: "2-digit", day: "2-digit" }} date={note.data.publishDate} />
  <div class="prose prose-sm prose-cactus mt-4 max-w-none [&>p:last-of-type]:mb-0" class:list={{ "line-clamp-6": isPreview }}>
    <Content />
  </div>
</article>
```

---

### 13. Webmentions Components

#### webmentions/index.astro

Webmentions container component.

```astro
---
import { getWebmentionsForUrl } from "@/utils/webmentions";
import Comments from "./Comments.astro";
import Likes from "./Likes.astro";

const url = new URL(Astro.url.pathname, Astro.site);
const webMentions = await getWebmentionsForUrl(`${url}`);

if (!webMentions.length) return;
---

<hr class="border-solid" />
<h2 class="mb-8 before:hidden">Webmentions for this post</h2>
<div class="space-y-10">
  <Likes mentions={webMentions} />
  <Comments mentions={webMentions} />
</div>
<p class="mt-8">Responses powered by <a href="https://webmention.io" rel="noreferrer" target="_blank">Webmentions</a></p>
```

#### webmentions/Likes.astro

Display like webmentions with avatars.

```astro
---
import { Image } from "astro:assets";
import type { WebmentionsChildren } from "@/types";

interface Props {
  mentions: WebmentionsChildren[];
}

const { mentions } = Astro.props;
const MAX_LIKES = 10;

const likes = mentions.filter((mention) => mention["wm-property"] === "like-of");
const likesToShow = likes.filter((like) => like.author?.photo && like.author.photo !== "").slice(0, MAX_LIKES);

{
  !!likes.length && (
    <div>
      <p class="text-accent-2 mb-0">
        <strong>{likes.length}</strong> {likes.length > 1 ? " People" : " Person"} liked this
      </p>
      {!!likesToShow.length && (
        <ul class="flex list-none flex-wrap overflow-hidden ps-2" role="list">
          {likesToShow.map((like) => (
            <li class="p-like h-cite -ms-2">
              <a class="u-url not-prose ..." href={like.author?.url} rel="noreferrer" target="_blank" title={like.author?.name}>
                <span class="p-author h-card">
                  <Image alt={like.author!.name} class="u-photo my-0 inline-block h-12 w-12" height={48} src={like.author!.photo} width={48} />
                </span>
              </a>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
```

#### webmentions/Comments.astro

Display comment/mention webmentions.

```astro
---
import { Image } from "astro:assets";
import { Icon } from "astro-icon/components";
import type { WebmentionsChildren } from "@/types";

interface Props {
  mentions: WebmentionsChildren[];
}

const { mentions } = Astro.props;
const validComments = ["mention-of", "in-reply-to"];
const comments = mentions.filter((mention) => validComments.includes(mention["wm-property"]) && mention.content?.text);

{
  !!comments.length && (
    <div>
      <p class="text-accent-2 mb-0">
        <strong>{comments.length}</strong> Mention{comments.length > 1 ? "s" : ""}
      </p>
      <ul class="divide-global-text/20 mt-0 divide-y ps-0" role="list">
        {comments.map((mention) => (
          <li class="p-comment h-cite my-0 flex items-start gap-x-5 py-5">
            {/* Author photo */}
            {/* Comment content */}
          </li>
        ))}
      </ul>
    </div>
  )
}
```

---

### 14. Layouts

#### Base.astro

Base layout with head, body, header, main, footer.

```astro
---
import BaseHead from "@/components/BaseHead.astro";
import Footer from "@/components/layout/Footer.astro";
import Header from "@/components/layout/Header.astro";
import SkipLink from "@/components/SkipLink.astro";
import ThemeProvider from "@/components/ThemeProvider.astro";
import { siteConfig } from "@/site.config";
import type { SiteMeta } from "@/types";

interface Props {
  meta: SiteMeta;
}

const { meta: { articleDate, description = siteConfig.description, ogImage, title } } = Astro.props;
---

<html class="scroll-smooth" lang={siteConfig.lang}>
  <head>
    <BaseHead articleDate={articleDate} description={description} ogImage={ogImage} title={title} />
    <ThemeProvider />
  </head>
  <body class="bg-global-bg text-global-text mx-auto flex min-h-screen max-w-3xl flex-col px-4 pt-16 font-mono text-sm font-normal antialiased sm:px-8">
    <SkipLink />
    <Header />
    <main id="main">
      <slot />
    </main>
    <Footer />
    <script is:inline type="speculationrules">
      {"prefetch": [{"where": {"href_matches": "/*"}, "eagerness": "immediate"}], "prerender": [{"where": {"href_matches": "/*"}, "eagerness": "moderate"}]}
    </script>
  </body>
</html>
```

#### BlogPost.astro

Blog post layout with TOC, scroll-to-top button.

```astro
---
import { type CollectionEntry, render } from "astro:content";
import Masthead from "@/components/blog/Masthead.astro";
import TOC from "@/components/blog/TOC.astro";
import WebMentions from "@/components/blog/webmentions/index.astro";
import BaseLayout from "./Base.astro";

interface Props {
  post: CollectionEntry<"post">;
}

const { post } = Astro.props;
const { ogImage, title, description, updatedDate, publishDate } = post.data;
const socialImage = ogImage ?? `/og-image/${post.id}.png`;
const articleDate = updatedDate?.toISOString() ?? publishDate.toISOString();
const { headings, remarkPluginFrontmatter } = await render(post);
const readingTime: string = remarkPluginFrontmatter.readingTime;
---

<BaseLayout meta={{ articleDate, description, ogImage: socialImage, title }}>
  <article class="grow break-words" data-pagefind-body>
    <div id="blog-hero" class="mb-12"><Masthead content={post} readingTime={readingTime} /></div>
    <div class="flex flex-col gap-10 lg:flex-row lg:items-start lg:justify-between">
      {!!headings.length && <TOC headings={headings} />}
      <div class="prose prose-sm prose-headings:font-semibold ...">
        <slot />
        <WebMentions />
      </div>
    </div>
  </article>
  <button class="hover:border-link fixed end-4 bottom-8 ..." id="to-top-btn">
    <span class="sr-only">Back to top</span>
    <svg ...><path d="M4.5 15.75l7.5-7.5 7.5 7.5" ...></path></svg>
  </button>
</BaseLayout>

<script>
  const scrollBtn = document.getElementById("to-top-btn") as HTMLButtonElement;
  const targetHeader = document.getElementById("blog-hero") as HTMLDivElement;

  function callback(entries: IntersectionObserverEntry[]) {
    entries.forEach((entry) => {
      scrollBtn.dataset.show = (!entry.isIntersecting).toString();
    });
  }

  scrollBtn.addEventListener("click", () => {
    document.documentElement.scrollTo({ behavior: "smooth", top: 0 });
  });

  const observer = new IntersectionObserver(callback);
  observer.observe(targetHeader);
</script>
```

---

## Site Configuration

### site.config.ts

```typescript
import type { AstroExpressiveCodeOptions } from "astro-expressive-code";
import type { SiteConfig } from "@/types";

export const siteConfig: SiteConfig = {
  url: "https://astro-cactus.chriswilliams.dev/",
  title: "Astro Cactus",
  author: "Chris Williams",
  description: "An opinionated starter theme for Astro",
  lang: "en-GB",
  ogLocale: "en_GB",
  date: {
    locale: "en-GB",
    options: { day: "numeric", month: "short", year: "numeric" },
  },
};

export const menuLinks: { path: string; title: string }[] = [
  { path: "/", title: "Home" },
  { path: "/about/", title: "About" },
  { path: "/posts/", title: "Blog" },
  { path: "/notes/", title: "Notes" },
];

export const expressiveCodeOptions: AstroExpressiveCodeOptions = {
  styleOverrides: {
    borderRadius: "4px",
    codeFontFamily: 'ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace',
    codeFontSize: "0.875rem",
    codeLineHeight: "1.7142857rem",
    codePaddingInline: "1rem",
    frames: { frameBoxShadowCssValue: "none" },
    uiLineHeight: "inherit",
  },
  themeCssSelector(theme, { styleVariants }) {
    if (styleVariants.length >= 2) {
      const baseTheme = styleVariants[0]?.theme;
      const altTheme = styleVariants.find((v) => v.theme.type !== baseTheme?.type)?.theme;
      if (theme === baseTheme || theme === altTheme) return `[data-theme='${theme.type}']`;
    }
    return `[data-theme="${theme.name}"]`;
  },
  themes: ["dracula", "github-light"],
  useThemedScrollbars: false,
};
```

---

## Tailwind Typography Config

```typescript
import type { Config } from "tailwindcss";

export default {
  plugins: [require("@tailwindcss/typography")],
  theme: {
    extend: {
      typography: () => ({
        DEFAULT: {
          css: {
            a: { textUnderlineOffset: "2px", "&:hover": { "@media (hover: hover)": { textDecorationColor: "var(--color-link)", textDecorationThickness: "2px" } } },
            blockquote: { borderLeftWidth: "0" },
            code: { border: "1px dotted #666", borderRadius: "2px" },
            kbd: { "&:where([data-theme='dark'], [data-theme='dark'] *)": { background: "var(--color-global-text)" } },
            hr: { borderTopStyle: "dashed" },
            strong: { fontWeight: "700" },
            sup: { marginInlineStart: "calc(var(--spacing) * 0.5)", a: { "&:after": { content: "']'" }, "&:before": { content: "'['" } } } },
            "tbody tr": { borderBottomWidth: "none" },
            "thead th": { borderBottom: "1px dashed #666", fontWeight: "700" },
            ".expressive-code, .admonition, .github-card": { marginTop: "calc(var(--spacing)*4)", marginBottom: "calc(var(--spacing)*4)" },
          },
        },
        sm: {
          css: { code: { fontSize: "var(--text-sm)", fontWeight: "400" } },
        },
      }),
    },
  },
} satisfies Config;
```