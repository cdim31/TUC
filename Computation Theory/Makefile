# Makefile for building and bulk‐generating C from .la files via mycompiler

# -------------------------------------------------------------------
# Compiler and source files
# -------------------------------------------------------------------
LEX_FILE    := mylexer.l
YACC_FILE   := myanalyzer.y
CGEN_FILE   := HelperFiles/cgen.c
EXEC        := mycompiler

# Generated sources from Flex/Bison
LEX_C       := lex.yy.c
YACC_C      := myanalyzer.tab.c
YACC_H      := myanalyzer.tab.h

# -------------------------------------------------------------------
# Directory of .la test inputs and corresponding .c outputs
# -------------------------------------------------------------------
LA_DIR      := Dimas_Christos_2021030183/
LA_FILES    := $(wildcard $(LA_DIR)/*.la)

# Output directory for generated .c files
OUT_DIR     := out
# Map each foo.la -> out/foo.c
C_FILES     := $(patsubst $(LA_DIR)/%.la, $(OUT_DIR)/%.c, $(LA_FILES))

# -------------------------------------------------------------------
# Phony targets
# -------------------------------------------------------------------
.PHONY: all run testall run-all clean

# -------------------------------------------------------------------
# Default: build the compiler
# -------------------------------------------------------------------
all: $(EXEC)

# -------------------------------------------------------------------
# Build rules
# -------------------------------------------------------------------
# 1) Generate parser with Bison
$(YACC_C) $(YACC_H): $(YACC_FILE)
	bison -d -v -r all $(YACC_FILE)

# 2) Generate lexer with Flex (depends on Bison header)
$(LEX_C): $(LEX_FILE) $(YACC_H)
	flex $(LEX_FILE)

# 3) Compile everything into the executable
$(EXEC): $(LEX_C) $(YACC_C) $(CGEN_FILE)
	gcc -o $(EXEC) $(LEX_C) $(YACC_C) $(CGEN_FILE) -lfl

# -------------------------------------------------------------------
# Single‐file run (prints to stdout)
# -------------------------------------------------------------------
run: all
	@echo "---- Running on example.la ----"
	@./$(EXEC) < example.la

# -------------------------------------------------------------------
# Bulk‐generate: produce out/foo.c for every foo.la in LA_DIR
# -------------------------------------------------------------------
testall: all | $(OUT_DIR) $(C_FILES)

# Ensure output directory exists
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# Pattern rule: LA_DIR/foo.la -> out/foo.c
$(OUT_DIR)/%.c: $(LA_DIR)/%.la
	@echo "---- Generating C for $< ----"
	@./$(EXEC) < $< > $@
	@echo "  -> wrote $@"

# -------------------------------------------------------------------
# Just run each .la and print to console (no files)
# -------------------------------------------------------------------
run-all: all
	@for f in $(LA_FILES); do \
	  echo "---- $$f ----"; \
	  ./$(EXEC) < $$f; \
	done

# -------------------------------------------------------------------
# Clean up generated artifacts
# -------------------------------------------------------------------
clean:
	rm -f $(EXEC) $(LEX_C) $(YACC_C) $(YACC_H) myanalyzer.output
	rm -rf $(OUT_DIR)
