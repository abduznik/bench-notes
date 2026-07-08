---
title: The scrollbar that wasn't allowed to exist
date: 2026-05-30
tags: [tailwind, css, dashboard, frontend]
domain: software
status: growing
---

## Context

Debugging a stuck, overlapping sidebar and completely broken scrolling on a local
dashboard (Hermes Agent, running at `127.0.0.1:9119`). The layout looked fine at
full screen. Shrink the window even slightly and the whole page locked up —
sidebar stuck half off-screen, no scrollbar, no way to reach content below the
fold.

## The bug

The dashboard layout used Tailwind's `lg:` breakpoint prefix, which only applies
above 1024px viewport width. Below that threshold, two things happened at once:

**1. The sidebar switched modes.**
Under 1024px it dropped out of the normal flex flow into `position: fixed` with
`-translate-x-full` — meant to slide off-screen for a mobile menu pattern. Instead
it just sat there, stuck, half-transitioned.

**2. The main content container lost its height constraint.**
Without the `lg:` flex-row layout active, the content area had nothing bounding
its height. It expanded to fit *all* its content — roughly 5716px worth — instead
of being capped at the viewport height.

That second part is what actually killed scrolling. A container can only scroll
if its content is taller than the container itself. Once the container's height
became "however tall the content is," `scrollHeight` and `clientHeight` became
equal. Nothing was overflowing anything, as far as the browser was concerned — so
there was nothing to scroll. Not a rendering bug. Not a CSS overflow bug. The
scrollbar wasn't broken; it correctly determined it had no reason to exist.

## The twist: the fix's own fix didn't work

The obvious repair — cap the container at `h-screen` / `max-h-screen` — did
nothing. Tailwind's own height utilities were resolving incorrectly, because a
custom `--theme-spacing-mul` CSS variable (used elsewhere in the theme system) was
interfering with how Tailwind v4 computes its spacing scale. The utility class was
present in the DOM, doing something, just not the thing its name promised.

Confirmed only by opening dev tools and checking computed height directly against
what the class was supposed to produce — the gap between "class is applied" and
"class is doing what it says" doesn't show up by reading the source.

## Fix

Bypass the abstraction that was lying, rather than trying to make it tell the
truth:

```css
/* web/src/index.css */
[data-layout-variant] {
  height: 100vh;
  max-height: 100vh;
  overflow: hidden;
}
[data-layout-variant] > .flex.min-h-0.w-full.min-w-0 {
  height: 100vh;
  max-height: 100vh;
  overflow: hidden;
}
```

Plus two structural changes: the sidebar became always `sticky` with
`translate-x-0` (never `fixed`, never off-screen), and the root layout kept its
`flex-row` unconditionally instead of gating it behind `lg:`.

## The general lesson
A utility class was present in the DOM and technically "applied," but it wasn't producing the effect its name promised, because a variable elsewhere in the system was silently reinterpreting how it resolved. Reading the source told a different story than checking the actual computed result at runtime — and that gap between "the code says X" and "the browser is actually doing Y" is where the real bug was hiding. The fix wasn't found by trying harder with the same utility classes; it took stepping outside the abstraction entirely and setting the computed values directly.