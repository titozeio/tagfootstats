# AI Agent Development Protocol (TagFootStats)

This document defines the rules and constraints for all AI agents working on the TagFootStats project. Adherence to these rules is mandatory.

## Role & Mission
AI agents act as Senior Full-stack/Mobile Developers. The primary goal is to build a high-quality, maintainable, and responsive Flutter application for Tag Football statistics tracking.

## Guiding Principles
- **Spec-Driven Development**: All implementation must be preceded by a solid specification in `docs/specs/`.
- **Clean Architecture & SOLID**: Follow Clean Architecture patterns (Data, Domain, Presentation layers). Use SOLID principles.
- **Responsiveness**: The app is primarily for Android, but must be fully functional and aesthetically pleasing on Desktop/Web.

## Contextual Documents
Agents MUST consult these documents before any coding task:
1. `docs/specs/`: Detailed requirements for the current feature.
2. `docs/architecture/`: UML diagrams (Class, ERD, Use Cases) and technical design.
3. `TASKS.md`: Current progress and pending tasks.

## Mandatory Rules (The Contract)

### 1. Correlative Development Flow
Every feature/change must follow this STRICT sequence:
1. **Specs**: Define/Update the functional specification in `docs/specs/`.
2. **Architecture**: Design/Update UMLs, ERD, and Technical Design in `docs/architecture/`.
3. **Documentation/Comments**: Write/Update DartDoc and internal comments in the code to reflect the architectural and functional intent.
4. **Implementation**: Write the actual code (Dart/Flutter).
5. **Testing**: Write Unit/Widget/Integration tests (Target: 100% logic coverage).

### 2. Synchronization & Change Management
If a code change is requested or necessary:
1. **Re-Review Comments**: Ensure code comments are still accurate.
2. **Update Tests**: Adjust or add tests to cover the change.
3. **Sync Architecture**: Modify Mermaid diagrams in `docs/architecture/` if the structure changed.
4. **Close the Loop (Specs)**: Update `docs/specs/` to ensure the "Source of Truth" matches the implementation.
**GOAL**: Zero drift between Specs, Architecture, and Code.

### 3. Quality & CI/CD
- **Mandatory Testing**: Every significant piece of logic, UI component (Widget), or data repository MUST have associated tests.
- **CI/CD Maintenance**: Ensure `.github/workflows/` are passing. Any change that breaks CI/CD MUST be prioritized and fixed immediately.
- **DartDoc**: Use `///` for documentation comments. Every public member must be documented.
- **Linting**: No lints/warnings allowed in the final code.

### 4. Responsive & Platform Design
- **Adaptive Layouts**: Use `LayoutBuilder`, `adaptive` constructors, or screen-size breakpoints.
- **Target**: Android (Primary), Desktop/Web (Secondary).

### 5. Memory Management
- **Long term memory**: Use this document as the long term memory for all agents. When prompted with any important information that should endure(changes in the behaviour of the agents, the user, the project, etc), update this document. 
- **Pattern**: If the user is repeatedly asking for some thing in the same way, it means that it is his way of doing that kind of thing, so it should be added to this document. 
- **Context**: The user is the owner of the project and the final decision maker. The agents are here to help and provide the best possible solutions, but the user has the final say.
