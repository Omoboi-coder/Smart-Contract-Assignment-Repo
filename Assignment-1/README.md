**Solidity Storage: Structs, Mappings, Arrays**

**Where are they stored?**
- **State variables:** `struct`, `mapping`, and `array` state variables (declared at contract level) are stored in contract **storage** (persistent, on-chain).
- **Local variables:** Value types (e.g., `uint`) are kept on the stack. Reference types like `struct` and `array` used inside functions must be declared `memory` (temporary copy) or `storage` (reference to persistent storage). `mapping` cannot be placed in `memory`—it only exists in `storage`.
- **Layout notes:** Simple state variables get a storage slot; structs' members are packed into consecutive slots; dynamic arrays store `length` at the variable slot and elements starting at `keccak256(slot)`. Mappings store values at `keccak256(h(key) . slot)` where `slot` is the mapping's declared slot.

**How they behave when executed or called**
- **Storage reads/writes:** Reading from or writing to storage is persistent and costs more gas. Changes to `storage` persist after the call.
- **Memory behavior:** Variables in `memory` are ephemeral for the call and cheaper; assigning a `storage` struct/array to a `memory` variable makes a copy.
- **Reference vs copy:** Declaring a local variable as `storage` creates a reference; mutating it changes the original state. Declaring `memory` creates an independent copy.
- **Mappings:** Accessing a non-existent key returns the default zero value for the value type (no exception). Mappings have O(1) access semantics but no iteration.
- **Arrays:** Dynamic arrays support `.push()`/`.pop()` (on storage arrays) and indexing; pushing changes storage `length` and writes the new element slot.

**Why you don't specify `memory` or `storage` with mappings**
- Mappings are allowed only in `storage` (they cannot exist in `memory`). When you declare a `mapping` as a state variable it is implicitly in storage, so there is no `memory` option to choose. Function parameters cannot be `memory` mappings; you can only work with mapping state variables or `storage` references to them.

**Quick examples (conceptual)**
- `mapping(address => uint) balances;` // stored in storage (persistent)
- `MyStruct memory temp = myStructs[0];` // `temp` is a copy in memory
- `MyStruct storage ref = myStructs[0];` // `ref` is a reference to storage
