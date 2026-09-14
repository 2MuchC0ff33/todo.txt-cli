# dedupe.awk - first-occurrence dedupe (projection only).
!seen[$0]++ { print }
