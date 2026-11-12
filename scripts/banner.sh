#!/usr/bin/env bash
set -euo pipefail

BOLD="\033[1m"
DIM="\033[2m"
WHITE="\033[97m"
GRAY="\033[90m"
RESET="\033[0m"

cat << "EOF"

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
  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝
EOF

echo -e "${GRAY}  ┌──────────────────────────────────────────────────────────────┐${RESET}"
echo -e "${GRAY}  │${RESET} ${BOLD}${WHITE}SYMFONY-HERMES-AUDIT${RESET} ${DIM}v1.0.0${RESET}                                  ${GRAY}│${RESET}"
echo -e "${GRAY}  │${RESET} ${DIM}Adversarial Tribunal • Hermes Self-Learning • Billion-Context${RESET} ${GRAY}│${RESET}"
echo -e "${GRAY}  ├──────────────────────────────────────────────────────────────┤${RESET}"
echo -e "${GRAY}  │${RESET} ${WHITE}Author:${RESET}  ${BOLD}kaszoka${RESET}                                             ${GRAY}│${RESET}"
echo -e "${GRAY}  │${RESET} ${WHITE}GitHub:${RESET}  ${BOLD}https://github.com/kaszoka/symfony-hermes-audit${RESET}     ${GRAY}│${RESET}"
echo -e "${GRAY}  │${RESET} ${WHITE}Install:${RESET} ${DIM}npx skills add kaszoka/symfony-hermes-audit${RESET}         ${GRAY}│${RESET}"
echo -e "${GRAY}  └──────────────────────────────────────────────────────────────┘${RESET}"
echo ""
