#!/usr/bin/env ruby

# $ gem install abnftt
require 'abnftt'

parser = ABNF.from_abnf(File.read("draft-ietf-jsonpath-base.abnf"))

require 'json'
tests = Dir["../json-path-comparison/queries/*/selector"]
# sorry, to much work to do this directly from github
# just check out git@github.com:cburgmer/json-path-comparison.git
# beside (at same directory level as) this repo

FAILING_CORRECTLY = %w(
array_slice_with_step_and_leading_zeros
bracket_notation_with_empty_path
bracket_notation_with_quoted_string_and_unescaped_single_quote
bracket_notation_with_two_literals_separated_by_dot
bracket_notation_with_two_literals_separated_by_dot_without_quotes
bracket_notation_without_quotes
current_with_dot_notation
dot_bracket_notation
dot_bracket_notation_with_double_quotes
dot_bracket_notation_without_quotes
dot_notation_after_recursive_descent_with_extra_dot
dot_notation_with_dash
dot_notation_with_double_quotes
dot_notation_with_double_quotes_after_recursive_descent
dot_notation_with_empty_path
dot_notation_with_key_root_literal
dot_notation_with_number
dot_notation_with_number_-1
dot_notation_with_number_on_object
dot_notation_with_single_quotes
dot_notation_with_single_quotes_after_recursive_descent
dot_notation_with_single_quotes_and_dot
dot_notation_with_space_padded_key
dot_notation_without_dot
dot_notation_without_root
dot_notation_without_root_and_dot
empty
filter_expression_with_addition
filter_expression_with_addition
filter_expression_with_boolean_and_operator_and_value_false
filter_expression_with_boolean_and_operator_and_value_true
filter_expression_with_boolean_or_operator_and_value_false
filter_expression_with_boolean_or_operator_and_value_true
filter_expression_with_division
filter_expression_with_dot_notation_with_dash
filter_expression_with_dot_notation_with_number
filter_expression_with_dot_notation_with_number_on_array
filter_expression_with_empty_expression
filter_expression_with_equals_array
filter_expression_with_equals_array_for_array_slice_with_range_1
filter_expression_with_equals_array_for_dot_notation_with_star
filter_expression_with_equals_array_or_equals_true
filter_expression_with_equals_array_with_single_quotes
filter_expression_with_equals_boolean_expression_value
filter_expression_with_equals_number_for_array_slice_with_range_1
filter_expression_with_equals_number_for_bracket_notation_with_star
filter_expression_with_equals_number_for_dot_notation_with_star
filter_expression_with_equals_number_with_leading_zeros
filter_expression_with_equals_object
filter_expression_with_in_array_of_values
filter_expression_with_in_current_object
filter_expression_with_length_function
filter_expression_with_local_dot_key_and_null_in_data
filter_expression_with_multiplication
filter_expression_with_negation_and_equals_array_or_equals_true
filter_expression_with_not_equals_array_or_equals_true
filter_expression_with_parent_axis_operator
filter_expression_with_regular_expression
filter_expression_with_regular_expression_from_member
filter_expression_with_set_wise_comparison_to_scalar
filter_expression_with_set_wise_comparison_to_set
filter_expression_with_single_equal
filter_expression_with_subtraction
filter_expression_with_triple_equal
filter_expression_with_value_false
filter_expression_with_value_null
filter_expression_with_value_true
function_sum
parens_notation
recursive_descent
recursive_descent_after_dot_notation
script_expression
)

success = true
tests.each do |fn|
  name = fn.split("/")[-2]
  sel = File.read(fn).chomp

  result = false
  begin
    parser.validate(sel)
    if FAILING_CORRECTLY.include?(name)
      warn "*** NOT FAILING ${name} #{sel}" 
      success = false
    end
    warn "OK: #{name}"
    result = true
  rescue => e
    wt = if FAILING_CORRECTLY.include?(name)
           "OK -- failing correctly:"
         else
           success = false
           "*** FAIL"
         end
    warn "#{wt} #{name} #{sel} #{e}" # XXX
  end
end
puts "---- successfully completed" if success
