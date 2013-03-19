#!/bin/bash

prog="$1"
struct="$2"

function print_struct_fields_rec {
  local pat='^ *(.+) (\**)([a-zA-Z_][a-zA-Z0-9_]*)(\[\])*;$'
  local pat_struct='^ *struct ([a-zA-Z_][a-zA-Z0-9_]*) '
  local pat_simple='^ *([a-zA-Z_][a-zA-Z0-9_]*) '

  local prog="$1"
  local struct="$2"
  local prefix="$3"
  local root_struct="${4:-$struct}"

  local IFS="|"
  for a in $(echo ptype struct $struct | gdb -q -n "$prog" | grep ";$" | tr '\n' '|'); do
    if [[ "$a" =~ $pat ]]; then
      local field_type="${BASH_REMATCH[1]}"
      local pointer_qual=${BASH_REMATCH[2]}
      local field=${prefix}${BASH_REMATCH[3]}
      local array_qual=${BASH_REMATCH[4]}
      local full_type="${field_type}${pointer_qual}${array_qual}"
      echo "printf \"${field},%d,%d,${full_type}\\n\", ((size_t)(&((struct $root_struct *)0)->${field})), sizeof(${full_type})"
      # Recurse into nested structs
      if [[ $pointer_qual = "" && $array_qual = "" ]]; then
        local sub_struct=""
        if [[ $a =~ $pat_struct ]]; then
          sub_struct=${BASH_REMATCH[1]}
        elif [[ $a =~ $pat_simple ]]; then
          simple=${BASH_REMATCH[1]}
          if [[ $simple != "char" && $simple != "short" && $simple != "signed" 
             && $simple != "unsigned" && $simple != "int" && $simple != "long"
             && $simple != "float" && $simple != "double" ]]; then
            sub_struct=$(echo ptype $simple | gdb -q -n "$prog" | awk '$4 == "struct" { print $5 }')
          fi
        fi
        if [[ $sub_struct != "" ]]; then
          print_struct_fields_rec "$prog" $sub_struct "${field}." $root_struct
        fi
      fi
    fi
  done
}

print_struct_fields_rec "$prog" $struct \
  | gdb -q -n "$prog" \
  | awk '$1 == "(gdb)" && $2 != "quit" { print $2 " " $3 " " $4 " " $5 }'

