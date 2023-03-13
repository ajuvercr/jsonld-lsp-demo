---
title: "Bringing IDE Support to JSON-LD with the Language Server Protocol"
date: \today
author:
- name: Arthur Vercruysse
  institute: Ghent University
- name: John Doe
  institute: Ghent University
institute: "Ghent University"
bibliography: "bibliography.bib"
link-citations: true
urlcolor: "blue"
keywords: "Linked Data, JSON-LD, Language Server"
abstract: |
  JSON-LD is a popular Linked Data serialization format used to describe and share structured data on the web. However, creating and editing JSON-LD documents can be a challenging task, especially when dealing with complex contexts including many properties. The existing JSON editing functionalities may not suffice for developers and a JSON-LD-aware editor could greatly enhance their experience. In this paper, we introduce a JSON-LD Language Server Protocol (LSP) that enables text editors compatible with the LSP protocol (e.g., Visual Studio Code and NeoVim), to suggest autocompleted items based on the defined JSON-LD context, and to rename identifiers inside the document accordingly. We believe that the implementation of our LSP will enhance developer ergonomics and promote the adoption of JSON-LD. Moreover, we see high potential for additional features that can be added to the JSON-LD LSP. For example, hovering, go-to-definition and code actions like flattening or structuring of JSON-LD documents, are possible features for future enhancements.
---

# Introduction

JSON-LD is a data serialization format that is used to describe semi-structured data on the web [@JSON-LD-W3C]. The premise of JSON-LD is simple: _just_ write JSON and annotate the document with a context to introduce unambiguous semantic annotations. _Just_ writing JSON becomes very tedious when the context grows and not all predicate and type definitions are easy to remember. Then it starts to feel like programming: only use fields that are defined or your data is broken. A JSON-LD dedicated editor might help to mitigate these problems.

As JSON-LD adoption continues to grow, introducing more complex contexts becomes difficult to manage, in particular in cases where contexts are provided as external resources. Major players in this field tend to follow this approach and promote open standards and application profiles by exposing JSON-LD contexts. For example, the Flemish initiative OSLO is working to achieve interoperability across Flanders by building semantic standards for different stakeholders such as government, industry and academia [@OSLO] <span style="color:red">[Make this a footnote link instead of a bibliographic reference]</span>. These efforts start by exposing complex JSON-LD contexts modeling concrete domains.

A dedicated JSON-LD editor can help the developer experience as they are powerful tools that allow users to receive feedback as they work. One way editors can provide feedback is by directly implementing domain-specific logic for a specific text syntax, although such solutions are not easily portable. An alternative an portable approach relies on the Language Server Protocol (LSP). LSP is a standard interface that separates the domain-specific logic from the editor's logic [@LSP-Multi], allowing editors to offer advanced features such as code completion, hover information and go-to-definition. By implementing an LSP for JSON-LD, developers can enjoy these advanced features and bring up their editor's capabilities for JSON-LD on par with popular programming languages.

<!-- What is the competition doing? JSON with JSON schema? Autocompletion with Yasgui? Turtle lsp (stardog) -->
Similar efforts have been made before on related Semantic Web syntaxes, but to the best of our knowledge, never for JSON-LD. For example, the Yasgui editor [@YASGUI] <span style="color:red">[Make this a footnote link instead of a bibliographic reference]</span>, a popular SPARQL human query interface, provides autocompletion based on the LOV API [@LOV] <span style="color:red">[You can cite [this](https://www.semantic-web-journal.net/content/linked-open-vocabularies-lov-gateway-reusable-semantic-vocabularies-web-1) paper instead]</span>. Additional plugins can add autocompletion based on domain knowledge, but these capabilities are built into the editor and can only be used with Yasgui. Stardog created open-source LSPs for turtle, TRIG, SPARQL, and more, however, they only support syntax correction and keyword auto-completion [@stardog].

Our demo JSON-LD LSP implementation is openly available at [github.com/ajuvercr/jsonld-lsp](https://github.com/ajuvercr/jsonld-lsp) (MIT).

# Language Server Protocol

The Language Server Protocol (LSP) is a JSON RPC protocol developed by Microsoft to simplify the process of integrating language-specific logic into an editor [@LSP]<span style="color:red">[Make this a footnote link instead of a bibliographic reference]</span>. Prior to LSP, editors had to implement each programming language they wanted to support individually, resulting in an $O(n*m)$ complexity where n is the number of editors and m is the number of programming languages. With LSP, editor and language-specific logic only needs to be implemented once, resulting in a much simpler $O(n+m)$ complexity [@LSP-Multi]. LSP only concerns itself with the source files of the program and doesn't involve building, running, or debugging. This is in contrast to the Build Server Protocol [@Builder-Server] <span style="color:red">[Make this a footnote link instead of a bibliographic reference]</span>.

To implement an LSP, one can support predefined functions like autocompletion, renaming, go-to-definition, find all references etc. Not everything needs to be implemented, as the editor and server can negotiate capabilities. For example, to support autocompletion the server will respond to _"textDocument/completion"_ events, fired by the editor to communicate the current cursor location. The server would respond then with a completion list, containing visual labels for the user, and text edits that change the document when one completion item is selected. While initializing, the server would also send a _"client/registerCapability"_ request to the client that informs the client of the autocompletion capability.

Overall, the Language Server Protocol greatly simplifies the process of integrating language-specific logic into an editor [@LSP-editor]. LSP has made it easier for developers to work with a wide range of programming languages and editors. Currently, there exist over 130 LSP servers that cover 99 different programming languages <span style="color:red">[Reference or link for this?]</span>.

# Demo

Our demo presents an implementation of a JSON-LD Language Server Protocol (LSP), developed using the Rust programming language and based on a basic LSP implementation [@crate-tower-lsp]. To extract predicate mappings from the context, we rely on the JSON-LD crate [@crate-jsonld] <span style="color:red">[Make this a footnote link instead of a bibliographic reference]</span>. The full source code and installation instructions can be found on GitHub (MIT) [@crate-jsonld-lsp] <span style="color:red">[Reference or link for this?]</span>.

\begin{figure}
\centering
\makebox[\textwidth][c]{
    \includegraphics[width=.7\linewidth]{./fig/completion.png}
    \includegraphics[width=.7\linewidth]{./fig/completion-id.png}
}
\caption{Screenshots showing completion functionality in NeoVim: left a list with all completion options, right a list containing the defined subject.}
\label{fig:complete}
\end{figure}

One of the key features of our LSP is code autocompletion based on the defined context. It extracts aliases from the inlined context, local contexts, and contexts hosted on the web. However, it currently does not take into account special context attributes such as context overloading or scoped contexts [@JSON-LD-W3C]. This is shown in action in Figure \ref{fig:complete}. The context defines two aliases, "name" and "knows". When the completion event is triggered, the user can choose between these aliases and the editor will complete the chosen alias. Defined subjects can be completed when writing `@`, but will expand to more involved objects.

\begin{figure}
\centering
\makebox[\textwidth][c]{
    \includegraphics[width=.7\linewidth]{./fig/rename-1-small.png}
    \includegraphics[width=.7\linewidth]{./fig/rename-2-small.png}
}
\caption{Screenshots showing renaming functionality in NeoVim: left NeoVim asks for the new name, right the subject is renamed.}
\label{fig:rename}
\end{figure}

Additionally, our LSP implementation supports renaming subjects. This is shown in Figure \ref{fig:rename}. The user is asked for the new name and the LSP server will respond with the required text changes that change all matching subjects to the new name.

<!--
This demo only shows a small part of the full potential of a JSON-LD LSP. If the LSP would interpret the context fully, it can give better suggestions based on context overloading and scoped contexts. The LSP can also be extended to interpret referred vocabularies to suggest compacted predicate notation, like `foaf:knows`. Yet, in its current form, the LSP can already help creating and editing JSON-LD documents, thus improving the developer experience.
-->

# Conclusion
 
This demonstration merely scratches the surface of the vast capabilities of a fully-fledged JSON-LD LSP server. By leveraging fully-interpreted contexts, the LSP would be able to provide more contextually-relevant suggestions, taking into account context overloading and scoped contexts. Additionally, LSP functionalities can be expanded to include the interpretation of referenced vocabularies, allowing autocompletion for compacted predicates, as for example `foaf:knows`. Despite its current limitations, the our LSP implementation already enhances the developer experience by facilitating the creation and editing of JSON-LD documents. We believe that by further improving available development tools, we contribute to increase the adoption of JSON-LD and Semantic Web technologies in general.
