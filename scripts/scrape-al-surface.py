#!/usr/bin/env python3
"""
Build al-surface.json from the local Microsoft docs repo.

Source: ~/Documents/Repos/community/dynamics365smb-devitpro-pb/
        dev-itpro/developer/methods-auto/

Each type directory contains one .md file per method overload.
Filename pattern: <type>-<method>[-<param-types>]-method.md

Output: scripts/al-surface.json
  {
    "Record": {
      "Insert": [
        {
          "syntax": "[Ok := ]  Record.Insert(RunTrigger: Boolean)",
          "parameters": [{"name": "RunTrigger", "type": "Boolean", "description": "..."}],
          "return_type": "Boolean",
          "return_optional": true,
          "doc_url": "https://learn.microsoft.com/.../record-insert-boolean-method",
          "file": "record/record-insert-boolean-method.md",
          "runtime_version": "1.0"
        },
        ...
      ]
    }
  }

Usage:
  python3 scripts/scrape-al-surface.py [--docs-root PATH] [--output PATH]
"""

import json
import re
import argparse
from pathlib import Path

DEFAULT_DOCS_ROOT = Path.home() / (
    "Documents/Repos/community/dynamics365smb-devitpro-pb"
    "/dev-itpro/developer/methods-auto"
)

DOC_BASE_URL = (
    "https://learn.microsoft.com/en-us/dynamics365/business-central"
    "/dev-itpro/developer/methods-auto"
)

# Types to skip — pure enums, not objects with methods
SKIP_TYPES = {
    "action", "auditcategory", "clienttype", "commitbehavior", "datascope",
    "defaultlayout", "errorbehavior", "errortype", "executioncontext",
    "executionmode", "fieldclass", "fieldtype", "httprequesttype",
    "inherentpermissionsscope", "isolationlevel", "none",
    "objecttype", "pagebackgroundtaskerrorlevel", "pagestyle",
    "permissionobjecttype", "promptmode", "reportformat", "reportlayouttype",
    "securityfilter", "securityoperationresult", "tableconnectiontype",
    "telemetryscope", "testpermissions", "transactionmodel", "transactiontype",
    "verbosity", "notificationscope", "textencoding", "xmlreadoptions",
    "xmlwriteoptions",
}

# Known compound type names (lowercase folder → display name)
TYPE_NAMES = {
    "biginteger": "BigInteger",
    "bigtext": "BigText",
    "blob": "Blob",
    "boolean": "Boolean",
    "byte": "Byte",
    "char": "Char",
    "code": "Code",
    "codeunit": "Codeunit",
    "companyproperty": "CompanyProperty",
    "cookie": "Cookie",
    "database": "Database",
    "datatransfer": "DataTransfer",
    "date": "Date",
    "dateformula": "DateFormula",
    "datetime": "DateTime",
    "debugger": "Debugger",
    "decimal": "Decimal",
    "dialog": "Dialog",
    "dictionary": "Dictionary",
    "dotnet": "DotNet",
    "duration": "Duration",
    "enum": "Enum",
    "errorinfo": "ErrorInfo",
    "fieldref": "FieldRef",
    "file": "File",
    "fileupload": "FileUpload",
    "filterpagebuilder": "FilterPageBuilder",
    "guid": "Guid",
    "httpclient": "HttpClient",
    "httpcontent": "HttpContent",
    "httpheaders": "HttpHeaders",
    "httprequestmessage": "HttpRequestMessage",
    "httpresponsemessage": "HttpResponseMessage",
    "instream": "InStream",
    "integer": "Integer",
    "isolatedstorage": "IsolatedStorage",
    "jsonarray": "JsonArray",
    "jsonobject": "JsonObject",
    "jsontoken": "JsonToken",
    "jsonvalue": "JsonValue",
    "keyref": "KeyRef",
    "label": "Label",
    "list": "List",
    "media": "Media",
    "mediaset": "MediaSet",
    "moduledependencyinfo": "ModuleDependencyInfo",
    "moduleinfo": "ModuleInfo",
    "navapp": "NavApp",
    "notification": "Notification",
    "numbersequence": "NumberSequence",
    "option": "Option",
    "outstream": "OutStream",
    "page": "Page",
    "query": "Query",
    "record": "Record",
    "recordid": "RecordId",
    "recordref": "RecordRef",
    "report": "Report",
    "requestpage": "RequestPage",
    "secrettext": "SecretText",
    "session": "Session",
    "sessioninformation": "SessionInformation",
    "sessionsettings": "SessionSettings",
    "system": "System",
    "taskscheduler": "TaskScheduler",
    "testaction": "TestAction",
    "testfield": "TestField",
    "testfilter": "TestFilter",
    "testfilterfield": "TestFilterField",
    "testhttprequestmessage": "TestHttpRequestMessage",
    "testhttpresponsemessage": "TestHttpResponseMessage",
    "testpage": "TestPage",
    "testpart": "TestPart",
    "testrequestpage": "TestRequestPage",
    "text": "Text",
    "textbuilder": "TextBuilder",
    "textconst": "TextConst",
    "time": "Time",
    "variant": "Variant",
    "version": "Version",
    "webserviceactioncontext": "WebServiceActionContext",
    "webserviceactionresultcode": "WebServiceActionResultCode",
    "xmlattribute": "XmlAttribute",
    "xmlattributecollection": "XmlAttributeCollection",
    "xmlcdata": "XmlCData",
    "xmlcomment": "XmlComment",
    "xmldeclaration": "XmlDeclaration",
    "xmldocument": "XmlDocument",
    "xmldocumenttype": "XmlDocumentType",
    "xmlelement": "XmlElement",
    "xmlnamespacemanager": "XmlNamespaceManager",
    "xmlnametable": "XmlNameTable",
    "xmlnode": "XmlNode",
    "xmlnodelist": "XmlNodeList",
    "xmlport": "XmlPort",
    "xmlprocessinginstruction": "XmlProcessingInstruction",
    "xmltext": "XmlText",
    "any": "Any",
}


def parse_method_md(path: Path, type_folder: str) -> dict | None:
    """Parse a single method .md file into a structured dict."""
    text = path.read_text(encoding="utf-8", errors="replace")

    # Skip non-method files (data type overview pages)
    if not (path.name.endswith("-method.md") or path.name.endswith("-procedure.md")):
        return None

    # --- method name from file stem ---
    # Pattern: <type>-<method>[-<overload-discriminator>]-method.md
    stem = path.stem  # e.g. "record-insert-boolean-method"
    for suffix in ("-method", "-procedure"):
        if stem.endswith(suffix):
            stem = stem[: -len(suffix)]

    # Remove type prefix
    if stem.startswith(type_folder + "-"):
        stem = stem[len(type_folder) + 1:]

    # Convert kebab → PascalCase
    method_name = "".join(w.capitalize() for w in stem.split("-"))

    # --- syntax ---
    syntax = ""
    syntax_match = re.search(r"## Syntax\s*```AL\s*(.*?)```", text, re.DOTALL)
    if syntax_match:
        syntax = syntax_match.group(1).strip()

    # --- parameters ---
    parameters = []
    params_section = re.search(r"## Parameters(.*?)(?=## |\Z)", text, re.DOTALL)
    if params_section:
        param_blocks = re.findall(
            r"\*([A-Za-z_][A-Za-z0-9_]*)\*\s*\n.*?Type:\s*\[?([^\]\n]+)\]?[^\n]*\n(.*?)(?=\n\*[A-Za-z]|\Z)",
            params_section.group(1),
            re.DOTALL,
        )
        for name, ptype, desc in param_blocks:
            parameters.append({
                "name": name.strip(),
                "type": ptype.strip().split("(")[0].strip(),
                "description": " ".join(desc.split()),
            })

    # --- return value ---
    return_type = ""
    return_optional = False
    rv_section = re.search(r"## Return Value(.*?)(?=## |\Z)", text, re.DOTALL)
    if rv_section:
        rv_text = rv_section.group(1)
        rt_match = re.search(r"Type:\s*\[?([^\]\n]+)\]?", rv_text)
        if rt_match:
            return_type = rt_match.group(1).strip().split("(")[0].strip()
        return_optional = "[Optional]" in rv_text

    # --- runtime version ---
    runtime_version = ""
    rv_match = re.search(r"runtime version\s+([\d.]+)", text, re.IGNORECASE)
    if rv_match:
        runtime_version = rv_match.group(1)

    # --- doc URL ---
    relative = f"{type_folder}/{path.name[:-3]}"  # strip .md
    doc_url = f"{DOC_BASE_URL}/{relative}"

    return {
        "method": method_name,
        "syntax": syntax,
        "parameters": parameters,
        "return_type": return_type,
        "return_optional": return_optional,
        "runtime_version": runtime_version,
        "doc_url": doc_url,
        "file": relative + ".md",
    }


def build_surface(docs_root: Path) -> dict:
    surface = {}

    type_dirs = sorted([d for d in docs_root.iterdir() if d.is_dir()])
    print(f"Found {len(type_dirs)} type directories")

    for type_dir in type_dirs:
        folder = type_dir.name
        if folder in SKIP_TYPES:
            continue

        type_name = TYPE_NAMES.get(folder, "".join(w.capitalize() for w in folder.split("-")))
        md_files = sorted(type_dir.glob("*.md"))

        methods: dict[str, list] = {}
        for md_file in md_files:
            parsed = parse_method_md(md_file, folder)
            if not parsed:
                continue
            m = parsed.pop("method")
            if m not in methods:
                methods[m] = []
            methods[m].append(parsed)

        if methods:
            surface[type_name] = methods
            print(f"  {type_name}: {len(methods)} methods, "
                  f"{sum(len(v) for v in methods.values())} overloads")

    return surface


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--docs-root",
        default=str(DEFAULT_DOCS_ROOT),
        help="Path to methods-auto directory in the local docs repo",
    )
    parser.add_argument(
        "--output",
        default=str(Path(__file__).parent / "al-surface.json"),
    )
    args = parser.parse_args()

    docs_root = Path(args.docs_root)
    if not docs_root.exists():
        print(f"ERROR: docs root not found: {docs_root}")
        print("Clone the docs repo or pass --docs-root")
        raise SystemExit(1)

    print(f"Reading from: {docs_root}")
    surface = build_surface(docs_root)

    out = Path(args.output)
    out.parent.mkdir(parents=True, exist_ok=True)
    with open(out, "w") as f:
        json.dump(surface, f, indent=2)

    total_types = len(surface)
    total_methods = sum(len(m) for m in surface.values())
    total_overloads = sum(
        len(ol) for methods in surface.values() for ol in methods.values()
    )
    print(f"\nDone.")
    print(f"  {total_types} types")
    print(f"  {total_methods} distinct methods")
    print(f"  {total_overloads} overloads")
    print(f"  Output: {out}")


if __name__ == "__main__":
    main()
