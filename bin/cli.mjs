#!/usr/bin/env node

import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { execSync } from 'node:child_process';
import * as p from '@clack/prompts';
import boxen from 'boxen';
import pc from 'picocolors';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const ASCII_BANNER = `
  ███████╗██╗   ██╗███╗   ███╗███████╗ ██████╗ ███╗   ██╗██╗   ██╗
  ██╔════╝╚██╗ ██╔╝████╗ ████║██╔════╝██╔═══██╗████╗  ██║╚██╗ ██╔╝
  ███████╗ ╚████╔╝ ██╔████╔██║█████╗  ██║   ██║██╔██╗ ██║ ╚████╔╝ 
  ╚════██║  ╚██╔╝  ██║╚██╔╝██║██╔══╝  ██║   ██║██║╚██╗██║  ╚██╔╝  
  ███████║   ██║   ██║ ╚═╝ ██║██║     ╚██████╔╝██║ ╚████║   ██║   
  ╚══════╝   ╚═╝   ╚═╝     ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   
  ██╗  ██╗███████╗██████╗ ███╗   ███╗███████╗███████╗
  ██║  ██║██╔════╝██╔══██╗████╗ ████║██╔════╝██╔════╝
  ███████║█████╗  ██████╔╝██╔████╔██║█████╗  ███████╗
  ██╔══██║██╔══╝  ██╔══██╗██║╚██╔╝██║██╔══╝  ╚════██║
  ██║  ██║███████╗██║  ██║██║ ╚═╝ ██║███████╗███████║
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝`;

const HARNESS_TARGETS = [
  {
    id: 'universal',
    label: 'Universal / Pi / Billion-Context (.agents/skills)',
    relPath: '.agents/skills/symfony-hermes-audit',
    globalPath: path.join(os.homedir(), '.agents/skills/symfony-hermes-audit'),
  },
  {
    id: 'claude',
    label: 'Claude Code (.claude/skills)',
    relPath: '.claude/skills/symfony-hermes-audit',
    globalPath: path.join(os.homedir(), '.claude/skills/symfony-hermes-audit'),
  },
  {
    id: 'opencode',
    label: 'OpenCode (.opencode/skills)',
    relPath: '.opencode/skills/symfony-hermes-audit',
    globalPath: path.join(os.homedir(), '.config/opencode/skills/symfony-hermes-audit'),
  },
  {
    id: 'cursor',
    label: 'Cursor (.cursor/skills + .cursor/rules bridge)',
    relPath: '.cursor/skills/symfony-hermes-audit',
    globalPath: path.join(os.homedir(), '.cursor/skills/symfony-hermes-audit'),
    bridgeFile: '.cursor/rules/symfony-hermes-audit.mdc',
  },
  {
    id: 'windsurf',
    label: 'Windsurf (.windsurf/skills)',
    relPath: '.windsurf/skills/symfony-hermes-audit',
    globalPath: path.join(os.homedir(), '.codeium/windsurf/skills/symfony-hermes-audit'),
    bridgeFile: '.windsurf/rules/symfony-hermes-audit.md',
  },
  {
    id: 'cline',
    label: 'Cline / Roo Code (.roo/skills)',
    relPath: '.roo/skills/symfony-hermes-audit',
    globalPath: path.join(os.homedir(), '.roo/skills/symfony-hermes-audit'),
  },
  {
    id: 'copilot',
    label: 'GitHub Copilot / Codex (.github/skills)',
    relPath: '.github/skills/symfony-hermes-audit',
    globalPath: path.join(os.homedir(), '.github/skills/symfony-hermes-audit'),
  },
];

function printHeader() {
  console.log(pc.white(pc.bold(ASCII_BANNER)));
  console.log(
    boxen(
      `${pc.bold(pc.white('SYMFONY-HERMES-AUDIT'))} ${pc.gray('v1.0.0')}\n` +
      `${pc.gray('Adversarial Subagent Tribunal • Hermes Self-Evolution • Billion-Context')}\n\n` +
      `${pc.white('Author:')}  ${pc.bold(pc.white('kaszoka'))}\n` +
      `${pc.white('GitHub:')}  ${pc.underline(pc.white('https://github.com/kaszoka/symfony-hermes-audit'))}\n` +
      `${pc.white('Command:')} ${pc.gray('npx skills add kaszoka/symfony-hermes-audit')}`,
      {
        padding: { top: 0, bottom: 0, left: 2, right: 2 },
        margin: { top: 0, bottom: 1, left: 2, right: 0 },
        borderStyle: 'single',
        borderColor: 'gray',
      }
    )
  );
}

async function main() {
  const args = process.argv.slice(2);
  printHeader();

  if (args.includes('--banner-only')) {
    process.exit(0);
  }

  p.intro(pc.bgWhite(pc.black(' MULTI-HARNESS INSTALLER • kaszoka/symfony-hermes-audit ')));

  const scope = await p.select({
    message: 'Wybierz zakres instalacji skilla:',
    options: [
      { value: 'project', label: 'Projekt lokalny (bieżący katalog roboczy)' },
      { value: 'global', label: 'Globalny (katalog domowy użytkownika dla wszystkich projektów)' },
    ],
  });

  if (p.isCancel(scope)) {
    p.cancel('Instalacja przerwana.');
    process.exit(0);
  }

  const selectedHarnesses = await p.multiselect({
    message: 'Wybierz harnesy AI, na których chcesz zainstalować skill (Spacja = zaznacz, Enter = zatwierdź):',
    options: HARNESS_TARGETS.map((h) => ({
      value: h.id,
      label: h.label,
    })),
    initialValues: ['universal', 'claude', 'cursor', 'opencode'],
    required: true,
  });

  if (p.isCancel(selectedHarnesses)) {
    p.cancel('Instalacja przerwana.');
    process.exit(0);
  }

  const syncDocs = await p.confirm({
    message: 'Czy pobrać teraz lokalną dokumentację Symfony (.rst) dopasowaną do composer.lock?',
    initialValue: true,
  });

  if (p.isCancel(syncDocs)) {
    p.cancel('Instalacja przerwana.');
    process.exit(0);
  }

  const spinner = p.spinner();
  spinner.start('Instalowanie plików skilla na wybranych harnesach...');

  const sourceSkillDir = path.resolve(__dirname, '../skills/symfony-hermes-audit');
  const installedPaths = [];

  for (const harnessId of selectedHarnesses) {
    const targetConfig = HARNESS_TARGETS.find((h) => h.id === harnessId);
    if (!targetConfig) continue;

    const destDir = scope === 'global' ? targetConfig.globalPath : path.resolve(process.cwd(), targetConfig.relPath);

    await fs.mkdir(path.dirname(destDir), { recursive: true });
    await fs.cp(sourceSkillDir, destDir, { recursive: true });
    installedPaths.push(destDir);

    // Jeśli Cursor w trybie lokalnym -> utwórz mostek .mdc
    if (harnessId === 'cursor' && scope === 'project' && targetConfig.bridgeFile) {
      const bridgePath = path.resolve(process.cwd(), targetConfig.bridgeFile);
      await fs.mkdir(path.dirname(bridgePath), { recursive: true });
      const mdcContent = [
        '---',
        'description: Autonomous Symfony Code Audit Skill (Adversarial Tribunal + Hermes Loop) by kaszoka',
        'globs: ["**/*.php", "**/*.yaml", "**/*.twig", "composer.json"]',
        'alwaysApply: false',
        '---',
        '',
        'Read and strictly follow all instructions in `.cursor/skills/symfony-hermes-audit/SKILL.md` and `.cursor/skills/symfony-hermes-audit/prompts/subagents-tribunal.md`.',
      ].join('\n');
      await fs.writeFile(bridgePath, mdcContent, 'utf8');
    }

    // Jeśli Windsurf w trybie lokalnym -> utwórz mostek .md
    if (harnessId === 'windsurf' && scope === 'project' && targetConfig.bridgeFile) {
      const bridgePath = path.resolve(process.cwd(), targetConfig.bridgeFile);
      await fs.mkdir(path.dirname(bridgePath), { recursive: true });
      const windsurfContent = [
        '# Symfony Hermes Audit Rule (by kaszoka)',
        '',
        'Trigger: Whenever reviewing or modifying Symfony/PHP files.',
        'Follow the instructions in `.windsurf/skills/symfony-hermes-audit/SKILL.md`.',
      ].join('\n');
      await fs.writeFile(bridgePath, windsurfContent, 'utf8');
    }
  }

  if (syncDocs && installedPaths.length !== 0) {
    spinner.message('Synchronizacja lokalnej dokumentacji Symfony (.rst)...');
    try {
      const syncScript = path.join(installedPaths[0], 'scripts/sync-symfony-docs.sh');
      execSync(`bash "${syncScript}"`, { stdio: 'ignore' });
    } catch {
      p.log.warn('Pominięto automatyczny klon symfony-docs (uruchom scripts/sync-symfony-docs.sh później).');
    }
  }

  spinner.stop(pc.white('Zakończono instalację na wybranych harnesach!'));

  console.log(
    boxen(
      `${pc.bold(pc.white('Zainstalowane lokalizacje:'))}\n` +
      installedPaths.map((pPath) => `  • ${pc.gray(pPath)}`).join('\n') +
      `\n\n${pc.white('Repozytorium:')} ${pc.underline(pc.white('https://github.com/kaszoka/symfony-hermes-audit'))}`,
      {
        padding: 1,
        margin: { top: 0, bottom: 1, left: 2, right: 0 },
        borderStyle: 'single',
        borderColor: 'white',
      }
    )
  );

  p.outro(pc.gray('Gotowe. Wywołaj /symfony-hermes-audit w swoim agencie AI.'));
}

main();
