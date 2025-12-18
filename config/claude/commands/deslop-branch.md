Check the diff against main, and remove all AI generated slop introduced in this branch

This includes:

- Extra comments that a human wouldn't write or is inconsistent with the rest of the file
- Extra defensive checks or try/catch blocks that are abnormal for that area of the codebase (especially if called by trusted / validated codepaths)
- Casts to anv to get around type issues
- Variables that are only used a single time right after declaration, prefer inlining the rhs.
- Any other style that is inconsistent with the file
  
Report at the end with a summary of what you changed
