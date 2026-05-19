# CS F363 Compiler Construction — Phase 2
## Elixir Language: Parser & Intermediate Code Generation
### Group G-27

---

## Team Members
| Name              | ID               |
|-------------------|------------------|
| Rishab Nagota     | 2022B1A71229H    |
| Kanav Sooden      | 2022B1A71558H    |
| Piyush Mahajan    | 2022B1A71231H    |
| Asmit Mukherjee   | 2022B5A70909H    |
| Rachit Bansal     | 2022B5A71642H    |

**Project Group ID: G-27**

---

## Files Included

| File               | Description                                              |
|--------------------|----------------------------------------------------------|
| `elixir.l`         | Flex lexer — returns tokens to Bison (updated Phase 1)   |
| `elixir.y`         | Bison parser with embedded TAC generator                 |
| `test_valid.elx`   | Valid input program (while loop + if statement)          |
| `test_error.elx`   | Input program with lexical and syntax errors             |
| `output_valid.txt` | Expected TAC output for the valid program                |
| `output_error.txt` | Expected error output for the error program              |
| `Makefile`         | Build and test automation                                |

---

## How to Build and Run

### Prerequisites
- `flex` (Lex)
- `bison` (Yacc)
- `gcc`

### Build
```bash
make
```

### Run Test Cases
```bash
make test
```

Or manually:
```bash
./elixir_compiler < test_valid.elx
./elixir_compiler < test_error.elx
```

---

## Phase 2 Overview

### 1. Parser (Bison / YACC)

The parser (`elixir.y`) implements the CFG defined in Phase 1:

- **Statements**: variable assignment, `if...do...end`, `while...do...end`
- **Expressions**: full precedence hierarchy (or → and → relational → additive → multiplicative → unary → primary)
- Operator precedence is encoded structurally in the grammar rules (no `%prec` directives needed)

### 2. Three-Address Code (TAC) Generator

TAC is generated inline within Bison semantic actions:

- Each binary expression creates a new temporary (`t0`, `t1`, …)
- Control flow (if/while) generates labels (`L0`, `L1`, …) and conditional/unconditional jumps
- TAC instructions emitted:
  - `t = a op b` — binary operation
  - `t = op a` — unary operation
  - `x = t` — assignment
  - `ifFalse cond goto L` — conditional branch
  - `goto L` — unconditional jump
  - `L:` — label definition

---

## TAC Example

**Input:**
```
x = 10
while x > 0 do
  x = x - 1
end
```

**Output TAC:**
```
x = 10
L0:
t0 = x > 0
ifFalse t0 goto L1
t1 = x - 1
x = t1
goto L0
L1:
```
