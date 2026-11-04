-- One row per source export, host player, and groundstroke.
-- Net/Out are recorded outcomes, not classifications of unforced errors.
CREATE VIEW IF NOT EXISTS `future-infusion-328319.tennis_analytics.match_stroke_summary` AS
SELECT
  source_file,
  host_player,
  stroke,
  COUNT(*) AS shots,
  COUNTIF(result = 'Net') AS net_errors,
  COUNTIF(result = 'Out') AS out_errors,
  ROUND(100.0 * COUNTIF(result = 'Net') / COUNT(*), 1) AS net_pct,
  ROUND(100.0 * COUNTIF(result = 'Out') / COUNT(*), 1) AS out_pct,
  ROUND(100.0 * COUNTIF(result IN ('Net', 'Out')) / COUNT(*), 1) AS net_out_pct
FROM `future-infusion-328319.tennis_analytics.shots`
WHERE player = host_player
  AND stroke IN ('Forehand', 'Backhand')
GROUP BY source_file, host_player, stroke;
