; Creation function identifiers

; Vide/Any function to a string arg
(function_call
  name: (identifier) @creator_name
)

; Fusion/Any method call to a string arg 'scope:New'
(function_call 
  name: (method_index_expression) @creator_name
)
