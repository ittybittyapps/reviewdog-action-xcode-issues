# GitHub Action: Xcode Issues with reviewdog

This action reports Xcode build issues (sourced from the JSON extracted from an Xcode `.xcresult` file) on pull requests with [reviewdog](https://github.com/reviewdog/reviewdog) to improve code reviews.

## Inputs

### `xcresult_json_file`

Path to xcresult file json file. You can get this using a command like the following:

```sh
xcrun xcresulttool get --format json --path MyProject.xcresult > xcresult.json
```

### `github_token`

Optional. `${{ github.token }}` is used by default.

### `level`

Optional. Report level for reviewdog [info,warning,error].
It's same as `-level` flag of reviewdog.

### `reporter`

Reporter of reviewdog command [github-pr-check,github-check,github-pr-review].
Default is github-pr-check.
It's same as `-reporter` flag of reviewdog.

github-pr-review can use Markdown and add a link to rule page in reviewdog reports.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [added,diff_context,file,nofilter]. Default is added.

### `fail_on_error`

Optional. Exit code for reviewdog when errors are found [true,false] Default is `false`.

### `reviewdog_flags`

Optional. Additional reviewdog flags.

## Example usage

```yml
name: Xcode Issues
on: [pull_request]
jobs:
  xcissues:
    name: "Xcode Issues"
    runs-on: ubuntu-latest
    steps:
      - name: Download xcresult JSON
        uses: actions/download-artifact@v2
        with:
          name: xcode-results.json
          path: xcode-results.json
      - name: Report Issues
        uses: ittybittyapps/reviewdog-action-xcode-issues@v1
        with:
          github_token: ${{ secrets.github_token }}
          xcresult_json_file: xcode-results.json
```
