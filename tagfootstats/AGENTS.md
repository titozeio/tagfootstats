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
1. **Code Generation**:
   - Always include unit/widget/integration tests (100% logic coverage).
   - Use `DartDoc` for all public classes and methods.
   - Follow Flutter's official style guide (`lints`).
2. **Documentation Maintenance**:
   - Update `docs/specs/` if requirements change.
   - Update `docs/architecture/` (UMLs/ERD) when modifying the system structure.
   - Maintain `TASKS.md` after completing a sub-task.
3. **Architecture Diagrams**:
   - Use Mermaid syntax for diagrams in markdown files.
4. **CI/CD**:
   - Ensure `.github/workflows/` are updated and passing.
5. **Firebase**:
   - Follow Firebase best practices for security rules and data modeling.
6. **Responsive Design**:
   - Use adaptive layouts to support mobile (Android) and desktop/web.
