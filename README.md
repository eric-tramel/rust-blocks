# rust-blocks

Code golfing -- how fast can we extract Markdown code blocks? 

Assume you have a big steam of Markdown text in STDIN. 

    ...a bunch of other text
    that might be included.
    
    ```python
    import numpy as np
    np.random.rand(3,3)
    ```

    And yet some other text.

    ```
    Unspecified language.
    ```

Your goal is to process all of that text to give you structured dataset
of code entries printed to STDOUT.

```json
[
    {
        "code": "import numpy as np\nnp.random.rand(3,3)\n",
        "syntax": "python"
    },
    {
        "code": "Unspecified language.",
        "syntax": null

    }
]
```

## Example

There is a naive rust example given in this repo. Build it and run the benchmark.

```
cargo build --release
```

Running this example gives the following performance on a base M4 Macbook.

```
➜ ./benchmark.sh
Checking for required dependencies...
All dependencies are satisfied.
Generating Markdown file with 100000 code blocks...
Markdown file 'large_input.md' generated successfully.
Starting benchmark with hyperfine...
Benchmark 1: cat "large_input.md" | "./target/release/rust-blocks" > /dev/null
  Time (mean ± σ):      43.7 ms ±   2.5 ms    [User: 25.7 ms, System: 9.7 ms]
  Range (min … max):    38.5 ms …  49.0 ms    30 runs

Benchmark completed.
```
