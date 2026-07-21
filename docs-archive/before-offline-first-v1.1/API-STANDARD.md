# LENS API Standard

## Prefix

`/api/v1`

## Success Shape

```json
{
  "success": true,
  "message": "Request completed.",
  "data": {}
}
```

## Error Shape

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {}
}
```

## Rules

- Use HTTP status codes correctly.
- Use Laravel API Resources.
- Never expose stack traces in production.
- Paginated responses must include pagination metadata.
- Mobile APIs require Sanctum authentication unless explicitly public.
- Device APIs require dedicated device credentials.
- Document every changed contract in `docs/api/`.
