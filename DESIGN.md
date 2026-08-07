# Flox ZFAKA Admin Design

## 1. Direction

Preserve the existing Tokyo admin shell and Layui controls. Product image management is an operational surface: compact, direct, and consistent with nearby product-management pages.

## 2. Layout

- Use the existing admin container, sidebar, tabs, notice block, and button styles.
- Display product images in a responsive thumbnail grid that wraps naturally on narrow screens.
- Keep upload actions above the grid and image-specific actions directly below each thumbnail.

## 3. Typography And Color

- Inherit all typography and color from the existing Tokyo/Layui styles.
- Use the existing success treatment for the primary-image marker.
- Use the existing danger button treatment for destructive actions.

## 4. Spacing

- Use the existing 4 px spacing rhythm.
- Thumbnail controls must remain separated and tappable on mobile.

## 5. Components And States

### Product Image Tile

- Fixed thumbnail area with preserved image aspect ratio.
- States: default, primary, uploading, failed.
- Actions: set primary, move earlier, move later, delete.

### Image Upload Queue

- Accept multiple image selection.
- Upload files sequentially so each request remains within the single-image limit.
- States: ready, uploading, completed, failed.

### Empty State

- Show the existing placeholder image and a direct upload action.

## 6. Responsive Behavior

- Desktop: multiple tiles per row.
- Mobile: two tiles per row where space permits, otherwise one full-width tile.
- Controls wrap instead of overflowing.

## 7. Accessibility

- Every image has descriptive alt text based on its position.
- All operations use native buttons.
- Primary state is conveyed by visible text, not color alone.

## 8. Accepted Debt

- The interface remains coupled to Layui because this task extends an existing legacy admin surface.
- Existing inline style conventions remain unchanged outside the product image page.
