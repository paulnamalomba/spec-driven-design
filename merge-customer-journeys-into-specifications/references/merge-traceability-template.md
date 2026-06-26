# Journey Merge Traceability Template

Use this table when merging customer journeys into specifications.

| Journey Source | Actor | Channel | Step / Rule | Affected Module | Change Type | Requirement ID | Requirement Text | Acceptance Criteria | Status / Decision |
|---|---|---|---|---|---|---|---|---|---|
| `A2 Make a Purchase` | Member | USSD | Enter merchant code and confirm merchant | Merchant / USSD | Add | USSD-### | System shall validate merchant codes before amount entry. | Invalid code shows retry message; valid code shows merchant name/location. | Planned |

## Change Type Definitions

- `Add`: new requirement not present in baseline.
- `Complement`: adds detail to an existing requirement.
- `Replace`: supersedes baseline behavior.
- `Delete/Deprecate`: removes or retires baseline behavior.
- `Question`: needs user/product decision.

## Validation Checklist

- All journey sections are represented.
- All money formulas are copied accurately.
- Every user confirmation screen has success and failure criteria.
- Requirements that imply integrations name the external system.
- Channel-specific requirements remain channel-specific unless explicitly shared.
