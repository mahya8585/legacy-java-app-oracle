# PostgreSQL Object Export Summary

Generated: 2026-04-03T15:26:05.036286

## Export Statistics

- **Total chunks processed**: 20
- **Total objects exported**: 77
- **Export errors**: 0

## Object Types Exported

- **FUNCTION**: 14 objects
- **INDEX**: 20 objects
- **PROCEDURE**: 14 objects
- **SCHEMA**: 1 objects
- **SEQUENCE**: 13 objects
- **TABLE**: 15 objects


## Mapping Types Used

- **one_to_one**: 56 objects
- **separate_index**: 20 objects
- **unknown_type**: 1 objects


## Directory Structure

The exported PostgreSQL objects follow the same structure as the original Oracle objects:

```
postgres/
├── SCHEMA1/
│   ├── TABLE/
│   │   ├── table1.sql
│   │   └── table2.sql
│   ├── VIEW/
│   │   └── view1.sql
│   ├── SEQUENCE/
│   │   └── seq1.sql
│   ├── INDEX/
│   │   └── idx1.sql
│   └── CONSTRAINT/
│       └── fk_constraint1.sql
└── SCHEMA2/
    └── ...
```

## Object Mapping Rules

1. **One-to-one**: TABLE, SEQUENCE, VIEW, FUNCTION, PROCEDURE, etc. → Individual files
2. **Consolidated in table**: PRIMARY KEY, CHECK, UNIQUE constraints → Included in table DDL
3. **Separate constraint files**: FOREIGN KEY constraints → Individual constraint files
4. **Separate index files**: INDEX, UNIQUE INDEX → Individual index files

