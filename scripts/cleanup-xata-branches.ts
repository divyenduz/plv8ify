import type { Types } from '@xata.io/api';
import { $ } from 'bun';
import chalk from 'chalk';
import stripAnsi from 'strip-ansi';
import invariant from 'tiny-invariant';

invariant(process.env.XATA_API_REFRESH_TOKEN, 'XATA_API_REFRESH_TOKEN is required');
invariant(process.env.XATA_API_ENVIRONMENT, 'XATA_API_ENVIRONMENT is required');
invariant(process.env.XATA_ORGANIZATION, 'XATA_ORGANIZATION is required');
invariant(process.env.XATA_PROJECT_ID, 'XATA_PROJECT_ID is required');

const organization = process.env.XATA_ORGANIZATION;
const projectId = process.env.XATA_PROJECT_ID;

console.log(chalk.cyan(`🔍 Looking for branches in project ${projectId}...`));

let branches: Types.BranchShortMetadata[] = [];

try {
  const branchesQuery = await $`xata branch list --organization=${organization} --project=${projectId} --json`.quiet();
  branches = branchesQuery.json();
} catch (e) {
  console.error(`Failed to get a list of branches`);
  console.error(e);
  process.exit(1);
}

console.log(chalk.cyan(`📊 Found ${chalk.bold(branches.length)} total branches`));

const branchesToDelete = branches.filter((branch) => branch.name !== 'main');
console.log(chalk.yellow(`🎯 Found ${chalk.bold(branchesToDelete.length)} non-main branches to delete`));

if (branchesToDelete.length === 0) {
  console.log(chalk.green('✅ No non-main branches found! Only main branch exists.'));
  process.exit(0);
}

console.log(chalk.gray('\nBranches to be deleted:'));
branchesToDelete.forEach((branch) => {
  console.log(chalk.gray(`  - ${branch.name} (${branch.id})`));
});

for (const branch of branchesToDelete) {
  try {
    console.log(chalk.red(`\n🗑️  Deleting branch: ${chalk.bold(branch.name)} (${branch.id})`));
    const deleteBranchQuery =
      await $`xata branch delete --organization=${organization} --project=${projectId} --branch=${branch.id} --yes --json`.quiet();
    const deleteBranch: Types.BranchShortMetadata = deleteBranchQuery.json();
    console.log(chalk.green(`✅ Deleted branch: ${chalk.bold(deleteBranch.name)}`));
  } catch (e) {
    console.error(`Failed to delete branch, branch id: ${branch.id}`);
    const errorMessage = e instanceof Error ? e.message : String(e);
    console.error(chalk.red(`❌ Error: ${errorMessage}`));
  }
}

console.log(chalk.green.bold(`\n✨ Branch cleanup completed!`));
console.log(chalk.cyan(`Remaining branches: main`));