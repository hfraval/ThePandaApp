# ``TPALogging``

Lightweight logging: a `LoggerProtocol` with leveled convenience methods and a default `Logger`.

## Overview

A tiny abstraction so the rest of the app logs through a protocol (mockable in tests) rather than
`print`. `LogLevel` orders severities; `Logger` is the default implementation. Mocks live in the
test-support framework.
