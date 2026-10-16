row = { "a" => "a", "b" => 1 }
p row.transform_values { |value|
  next value unless value.is_a?(String)

  value.tr("a", "x")
}
