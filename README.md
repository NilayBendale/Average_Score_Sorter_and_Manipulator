# Average Score Sorter and Manipulator

A compact MIPS assembly program that collects assignment scores, sorts them in **descending** order, optionally **drops the lowest N**, and prints the **rounded‑down average** of the remaining scores.

---

## ✨ Features

* **Input & Validation**: Prompts for number of assignments (1–25) and each score.
* **Selection Sort (desc)**: Copies the input array to a second array and sorts it high→low.
* **Recursive Summation**: Computes the sum of the top `n - drop` elements using a recursive routine.
* **Rounded‑Down Average**: Integer division yields a floor average.
* **Clean I/O**: Structured prompts and output lines for grading scripts.

> Note: This is a teaching/learning project; it favors clarity in register usage, stack frames, and syscall usage over micro‑optimizations.

---

## 📁 Files

* `avgScores.s` — main implementation
* `avgScores (1).s` — alternate version with equivalent logic/comments (optional)

---

## 🧠 How It Works

1. **Read count** `numScores` (validated in range 1–25).
2. **Read scores** into `orig`.
3. **Print** the original array via `printArray`.
4. **Copy** `orig → sorted` and **selection sort** `sorted` in descending order.
5. **Print** the sorted array.
6. **Read drop** `d` (validated `0 ≤ d < numScores`; all‑dropped case handled).
7. **Sum top** `k = numScores − d` elements with `calcSum` (recursive), then **average** via integer division.

---

## 🔧 Build & Run (MARS)

1. Download the \[MARS MIPS simulator].
2. Open `avgScores.s` in MARS.
3. Assemble (`F3`) and Run (`F5`).

**Syscalls used**:

* `print_string (v0=4)`
* `print_int (v0=1)`
* `read_int (v0=5)`
* `exit (v0=10)`

---

## ⌨️ Program I/O

**Prompts** (verbatim):

* `Enter the number of assignments (between 1 and 25): `
* `Enter score: ` (repeated `numScores` times)
* `Sorted scores (in descending order): ` (followed by values)
* `Enter the number of (lowest) scores to drop: `
* `Average (rounded down) with dropped scores removed: `
* `All scores dropped!` (when `drop == numScores`)
* `-- program is finished running ––`

**Printed arrays**: elements are separated by a single space; a newline is printed at the end.

---

## 🧪 Example 

```
Enter the number of assignments (between 1 and 25): 5
Enter score: 2
Enter score: 22
Enter score: 11
Enter score: 7
Enter score: 19
Original scores: 2 22 11 7 19
Sorted scores (in descending order): 22 19 11 7 2
Enter the number of (lowest) scores to drop: 2
Average (rounded down) with dropped scores removed: 17
-- program is finished running ––
```

---

## 🧵 Implementation Notes

* **Data**: two arrays of 25 words: `orig`, `sorted`.
* **Registers**: `$s0` (count), `$s1` (orig base), `$s2` (sorted base), `$s3` (drop); `$t0–$t9` temporaries.
* **`printArray`**: saves RA/args on stack; iterates and prints `a[i]` followed by a space; terminates with newline.
* **`sel_sort`**: classic selection sort using index of current maximum; swaps values in `sorted`.
* **`calcSum` (recursive)**: base case `n ≤ 0 → 0`; else returns `a[n−1] + calcSum(a, n−1)` with stack‑stored frame locals.
* **Average**: integer division of sum by kept count (`numScores − drop`).

---

## ⚠️ Edge Cases & Behavior

* **Invalid count**: Re‑prompts until `1 ≤ numScores ≤ 25`.
* **Score of 0**: Triggers a restart to the count prompt (simple input‑sanity choice).
* **Invalid drop**: Re‑prompts unless `0 ≤ drop < numScores`; when `drop == numScores`, prints `All scores dropped!` and exits cleanly.
* **Rounding**: Integer division floors toward zero (expected in grading scripts).

---

> Implemented **Average_Score_Sorter_and_Manipulator**, a MIPS assembly program that sorts scores, drops the lowest N, and computes a floor average using a recursive summation routine and clean stack discipline.

---

## 📄 License

no licence 
