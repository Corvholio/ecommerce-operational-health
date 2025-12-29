# View Design Rationale

## Executive Health View
Purpose:
- Monitor system-level operational health
- Detect early signals rather than explain causes

Grain:
- Monthly

Why:
- Reduces noise
- Enables trend detection
- Suitable for leadership monitoring

## Product Category Health View
Purpose:
- Prioritize investigation when system signals appear

Grain:
- Product category (aggregated)
- Scoped to top contributors by volume

Why:
- Focus attention where customer exposure is highest
- Avoid over-weighting long-tail categories
- Use relative performance instead of arbitrary thresholds

## Design Principle
Each view operates at a single, intentional grain and is not
designed to be a catch-all reporting tool.
