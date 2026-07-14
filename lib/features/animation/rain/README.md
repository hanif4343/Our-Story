# Animation: rain

Architecture placeholder only — **not implemented in v1.0.0 Foundation**,
per project spec ("Do NOT implement yet. Only architecture.").

This folder is reserved for the rain overlay animation renderer.

When implemented, it should:
- Expose a single `RainOverlay extends StatelessWidget` (or
  `AnimatedWidget`) widget.
- Accept a lightweight, immutable config object (intensity, duration,
  loop) via its constructor — no external state coupling.
- Be registered in `AnimationOverlayFactory`
  (features/animation/animation_overlay_factory.dart) against
  `AnimationType.rain`
  (see features/animation/domain/animation_type.dart).
- Stay allocation-light: prefer `CustomPainter` / `Transform` over
  building large widget trees per particle for 60fps performance.
