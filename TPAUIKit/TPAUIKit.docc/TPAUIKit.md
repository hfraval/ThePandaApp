# ``TPAUIKit``

The design system and the view-composition system: how screens are built as trees of small view
controllers, plus the shared visual tokens.

## Overview

`TPAUIKit` provides two things:

- **A view-composition system.** Instead of one massive view controller per screen, a screen is a
  *tree* of small ones. ``Content`` makes a view controller composable;
  ``StackContentViewController`` stacks children; ``CoordinatedStackContentViewController``
  drives its children from one immutable **content model**. See <doc:CoordinatedContent>.
- **Design-system tokens.** ``AppColors``, ``AppTypography``, ``AppImageAsset`` and ``SystemIcon``
  centralise the brand-aware look, and ``LoadingView`` is a shared component.

The provider→view "data flows down" contract uses weak, type-erased delegates
(``ViewModelProviderDelegate`` / ``ContentModelProviderDelegate``) so providers can push immutable
models without retain cycles.

## Topics

### View composition

- ``Content``
- ``StackContentViewController``
- ``CoordinatedStackContentViewController``

### Coordinated content

- ``CoordinatedContent``
- ``AnyCoordinatedContent``
- ``ClosureCoordinatedContent``
- ``CoordinatedContentUpdate``

### Provider delegates

- ``ViewModelProviderDelegate``
- ``AnyViewModelProviderDelegate``
- ``ContentModelProviderDelegate``
- ``AnyContentModelProviderDelegate``

### Design system

- ``AppColors``
- ``AppTypography``
- ``AppImageAsset``
- ``SystemIcon``
- ``LoadingView``

### Concepts

- <doc:CoordinatedContent>
