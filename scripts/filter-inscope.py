#!/usr/bin/env python3
"""
filter-inscope.py — reads al-surface.json and produces al-surface-inscope.json.

Each overload entry gets an added field:
  "scope": "in-scope" | "out-of-scope" | "test-only"

"test-only" = types only usable from [Test] codeunits (TestPage, TestField, etc.)
"out-of-scope" = features the runner does not support (File, HttpClient, SMTP, etc.)
"in-scope" = everything else the runner is designed to cover
"""

import json
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent

# Types that exist solely for Test codeunit use — still included, flagged separately
TEST_ONLY_TYPES = {
    "TestAction",
    "TestField",
    "TestFilter",
    "TestHttpRequestMessage",
    "TestHttpResponseMessage",
    "TestPage",
    "TestPart",
    "TestRequestPage",
}

# Types fully out of scope — runner cannot execute these
OUT_OF_SCOPE_TYPES = {
    "File",          # File.Upload / File.Download (browser round-trip)
    "FileUpload",    # browser-side upload
    "HttpClient",    # throws in runner
    "HttpContent",   # HttpClient companion
    "HttpHeaders",   # HttpClient companion
    "HttpRequestMessage",   # HttpClient companion
    "HttpResponseMessage",  # HttpClient companion
    "Cookie",        # HTTP / browser
    "FilterPageBuilder",    # UI-only, no runner support
    "Media",         # blob media upload — browser round-trip
    "MediaSet",      # same
    "Debugger",      # debugger API — not testable
    "XmlPort",       # report-like rendering
    "Query",         # query objects — no runner support for execution
    "Page",          # Page.Run etc. — not TestPage dispatch
    "Report",        # report rendering; RequestPage handler is in-scope via RequestPage type
    "IsolatedStorage",  # tenant/module isolated key-value — session-unsafe in test context
    "TaskScheduler",    # background job scheduling — out of scope
    "NumberSequence",   # sequence increment — stateful side effects, out of scope for now
    "WebServiceActionContext",  # OData/SOAP endpoints
    "Dialog",        # UI dialogs — not capturable in runner without handler
    "RequestPage",   # in plan as "no rendering", but RequestPage type is handler-dispatch only
    "Productname",   # read-only product name constants — trivial, no runner support needed
    "SecretText",    # secret text — no runner support for secret injection
    "SessionSettings", # session settings — UI-level, not testable
    "XmlPort",       # rendering
}

# Types in-scope (the runner is designed to support these)
# Everything not in OUT_OF_SCOPE_TYPES and not in TEST_ONLY_TYPES is in-scope.
# We enumerate explicitly to be precise.
IN_SCOPE_TYPES = {
    "Record",
    "RecordRef",
    "FieldRef",
    "KeyRef",
    "RecordId",
    "Codeunit",
    "ErrorInfo",
    "Text",
    "TextBuilder",
    "TextConst",
    "BigText",
    "Label",
    "JsonObject",
    "JsonArray",
    "JsonToken",
    "JsonValue",
    "XmlDocument",
    "XmlElement",
    "XmlAttribute",
    "XmlAttributeCollection",
    "XmlCData",
    "XmlComment",
    "XmlDeclaration",
    "XmlDocumentType",
    "XmlNamespaceManager",
    "XmlNameTable",
    "XmlNode",
    "XmlNodeList",
    "XmlProcessingInstruction",
    "XmlText",
    "InStream",
    "OutStream",
    "Blob",
    "Date",
    "DateTime",
    "Time",
    "Duration",
    "Integer",
    "BigInteger",
    "Decimal",
    "Boolean",
    "Byte",
    "Guid",
    "Variant",
    "Enum",
    "List",
    "Dictionary",
    "NavApp",
    "ModuleInfo",
    "ModuleDependencyInfo",
    "Notification",
    "Session",
    "SessionInformation",
    "CompanyProperty",
    "System",
    "Database",
    "DataTransfer",  # in-scope as "test that it throws outside upgrade context"
    "Version",
}


def classify_type(type_name: str) -> str:
    if type_name in TEST_ONLY_TYPES:
        return "test-only"
    if type_name in OUT_OF_SCOPE_TYPES:
        return "out-of-scope"
    if type_name in IN_SCOPE_TYPES:
        return "in-scope"
    # Unknown types — flag as out-of-scope with a warning
    print(f"  WARNING: unknown type '{type_name}' — defaulting to out-of-scope", file=sys.stderr)
    return "out-of-scope"


def main():
    surface_path = SCRIPT_DIR / "al-surface.json"
    out_path = SCRIPT_DIR / "al-surface-inscope.json"

    print(f"Reading {surface_path}...")
    with open(surface_path) as f:
        data = json.load(f)

    result = {}
    counts = {"in-scope": 0, "out-of-scope": 0, "test-only": 0}
    type_counts = {"in-scope": 0, "out-of-scope": 0, "test-only": 0}

    for type_name in sorted(data.keys()):
        methods = data[type_name]
        scope = classify_type(type_name)
        type_counts[scope] += 1
        result[type_name] = {}
        for method_name, overloads in methods.items():
            annotated = []
            for ov in overloads:
                entry = dict(ov)
                entry["scope"] = scope
                annotated.append(entry)
                counts[scope] += 1
            result[type_name][method_name] = annotated

    print(f"Writing {out_path}...")
    with open(out_path, "w") as f:
        json.dump(result, f, indent=2)

    print()
    print("=== Summary ===")
    print(f"Types:     {type_counts['in-scope']:4d} in-scope  |  {type_counts['out-of-scope']:4d} out-of-scope  |  {type_counts['test-only']:4d} test-only")
    print(f"Overloads: {counts['in-scope']:4d} in-scope  |  {counts['out-of-scope']:4d} out-of-scope  |  {counts['test-only']:4d} test-only")
    print(f"Total types: {sum(type_counts.values())}  |  Total overloads: {sum(counts.values())}")


if __name__ == "__main__":
    main()
