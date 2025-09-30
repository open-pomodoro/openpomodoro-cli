package cmd

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestFormatKeyValue(t *testing.T) {
	tests := []struct {
		name     string
		key      string
		value    string
		expected string
	}{
		{
			name:     "simple value without special chars",
			key:      "description",
			value:    "SimpleValue",
			expected: "description=SimpleValue",
		},
		{
			name:     "value with space requires quoting",
			key:      "description",
			value:    "Has Space",
			expected: `description="Has Space"`,
		},
		{
			name:     "value with tab requires quoting",
			key:      "description",
			value:    "Has\tTab",
			expected: "description=\"Has\tTab\"",
		},
		{
			name:     "value with newline requires quoting",
			key:      "description",
			value:    "Has\nNewline",
			expected: "description=\"Has\nNewline\"",
		},
		{
			name:     "value with quote requires quoting and escaping",
			key:      "description",
			value:    `Has "Quote"`,
			expected: `description="Has \"Quote\""`,
		},
		{
			name:     "value with backslash requires quoting and escaping",
			key:      "description",
			value:    `Has\Backslash`,
			expected: `description="Has\\Backslash"`,
		},
		{
			name:     "value with both backslash and quote",
			key:      "description",
			value:    `Has \"Both\"`,
			expected: `description="Has \\\"Both\\\""`,
		},
		{
			name:     "empty value",
			key:      "tags",
			value:    "",
			expected: "tags=",
		},
		{
			name:     "multiple special characters",
			key:      "description",
			value:    "Space and\ttab and\nnewline",
			expected: "description=\"Space and\ttab and\nnewline\"",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := formatKeyValue(tt.key, tt.value)
			assert.Equal(t, tt.expected, got)
		})
	}
}