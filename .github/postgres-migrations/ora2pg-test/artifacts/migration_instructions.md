# Migration Instructions

This file allows you to provide custom instructions to the AI agents performing the Oracle to PostgreSQL migration.

## How to Use This File

1. **Leave as-is for default behavior**: If you don't need custom instructions, leave this file unchanged.

2. **Add custom patterns**: Include specific conversion patterns, naming conventions, or business rules.

3. **Provide context**: Add information about your application's specific requirements.

4. **Reference documentation**: Link to relevant documentation or standards your team follows.

## Example Custom Instructions

```
- Use snake_case for all table and column names
- Prefix all sequences with 'seq_'
- Convert Oracle ROWNUM to PostgreSQL LIMIT/OFFSET patterns
- Preserve existing trigger logic but modernize syntax
```

**Template hash: migration_instructions_default_v1.0**