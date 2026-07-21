# API Conventions

## Base Path

`/api/v1`

## Example Success Response

```json
{
  "data": {},
  "message": "Request completed successfully."
}
```

## Example Validation Error

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "field": ["Validation message"]
  }
}
```

## Rules

- Use API Resources for response shaping.
- Use pagination for collections that can grow.
- Use ISO 8601 timestamps.
- Avoid returning internal exception details.
- Authorize every protected resource.
- Document breaking changes before implementation.
