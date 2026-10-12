import 'dart:ui';

// Dots for Connect the Dots, traced from each picture's outline (page coordinates).
// Generated; every set was checked by eye. The boat is left out (its sails
// are separate from the hull, so the outline makes no sense).

class ConnectDotsData {
  /// Subjects that work at each dot count.
  static const Map<int, List<String>> subjects = {
    10: ['apple', 'banana', 'barn', 'car', 'fish', 'pumpkin', 'rocket', 'strawberry', 'tomato', 'carrot'],
    15: ['apple', 'banana', 'barn', 'butterfly', 'car', 'carrot', 'chicken', 'corn', 'cow', 'elephant', 'fish', 'pumpkin', 'rocket', 'strawberry', 'tomato', 'tractor', 'train', 'turtle'],
    20: ['apple', 'banana', 'barn', 'butterfly', 'car', 'carrot', 'chicken', 'corn', 'cow', 'elephant', 'fish', 'grapes', 'pumpkin', 'rocket', 'strawberry', 'tomato', 'tractor', 'train', 'turtle'],
  };

  static const Map<String, Map<int, List<Offset>>> dots = {
    'apple': {
      10: [Offset(520.8, 141.1), Offset(817.8, 188.1), Offset(707.4, 297.6), Offset(831.0, 520.3), Offset(764.3, 670.1), Offset(697.6, 819.9), Offset(432.8, 865.5), Offset(258.3, 747.3), Offset(195.7, 474.5), Offset(257.7, 216.5)],
      15: [Offset(520.8, 141.1), Offset(581.7, 216.4), Offset(817.8, 188.1), Offset(707.4, 297.6), Offset(793.0, 370.3), Offset(831.0, 520.3), Offset(800.1, 682.8), Offset(697.6, 819.9), Offset(432.8, 865.5), Offset(258.3, 747.3), Offset(195.7, 474.5), Offset(320.3, 295.9), Offset(257.7, 216.5), Offset(380.2, 192.7), Offset(478.5, 248.4)],
      20: [Offset(520.8, 141.1), Offset(581.7, 216.4), Offset(692.7, 165.8), Offset(817.8, 188.1), Offset(707.4, 297.6), Offset(793.0, 370.3), Offset(831.0, 520.3), Offset(800.1, 682.8), Offset(697.6, 819.9), Offset(591.2, 865.5), Offset(432.8, 865.5), Offset(345.6, 806.4), Offset(258.3, 747.3), Offset(201.2, 606.8), Offset(195.7, 474.5), Offset(231.6, 369.4), Offset(320.3, 295.9), Offset(257.7, 216.5), Offset(380.2, 192.7), Offset(478.5, 248.4)],
    },
    'banana': {
      10: [Offset(349.2, 176.4), Offset(382.2, 383.6), Offset(497.5, 569.5), Offset(671.1, 671.4), Offset(918.1, 687.0), Offset(954.3, 791.5), Offset(582.3, 779.4), Offset(433.0, 716.9), Offset(294.1, 562.7), Offset(226.9, 191.2)],
      15: [Offset(349.2, 176.4), Offset(382.2, 383.6), Offset(497.5, 569.5), Offset(671.1, 671.4), Offset(816.0, 701.3), Offset(961.0, 731.2), Offset(908.7, 809.7), Offset(817.8, 767.7), Offset(697.4, 788.2), Offset(582.3, 779.4), Offset(433.0, 716.9), Offset(294.1, 562.7), Offset(255.5, 463.8), Offset(241.2, 327.5), Offset(226.9, 191.2)],
      20: [Offset(349.2, 176.4), Offset(358.3, 295.0), Offset(382.2, 383.6), Offset(420.0, 467.2), Offset(497.5, 569.5), Offset(595.9, 641.6), Offset(671.1, 671.4), Offset(918.1, 687.0), Offset(961.0, 731.2), Offset(954.3, 791.5), Offset(864.8, 799.6), Offset(817.8, 767.7), Offset(697.4, 788.2), Offset(582.3, 779.4), Offset(433.0, 716.9), Offset(354.1, 648.3), Offset(294.1, 562.7), Offset(255.5, 463.8), Offset(241.2, 327.5), Offset(226.9, 191.2)],
    },
    'barn': {
      10: [Offset(512.0, 153.0), Offset(749.8, 286.1), Offset(811.0, 507.0), Offset(810.0, 691.0), Offset(808.9, 874.9), Offset(512.0, 874.9), Offset(215.1, 874.9), Offset(174.0, 687.1), Offset(133.0, 499.3), Offset(275.0, 285.1)],
      15: [Offset(512.0, 153.0), Offset(630.9, 219.6), Offset(749.8, 286.1), Offset(889.4, 504.4), Offset(811.0, 507.0), Offset(807.5, 692.0), Offset(804.0, 877.0), Offset(656.8, 876.5), Offset(509.5, 876.0), Offset(362.3, 875.5), Offset(215.1, 874.9), Offset(214.0, 691.0), Offset(213.0, 507.0), Offset(133.0, 499.3), Offset(275.0, 285.1)],
      20: [Offset(515.4, 153.9), Offset(632.6, 220.0), Offset(749.8, 286.1), Offset(817.3, 396.5), Offset(884.7, 507.0), Offset(811.0, 507.0), Offset(809.2, 599.5), Offset(807.5, 692.0), Offset(805.8, 784.5), Offset(804.0, 877.0), Offset(656.2, 875.2), Offset(508.5, 873.5), Offset(360.8, 871.8), Offset(213.0, 870.0), Offset(213.0, 688.5), Offset(213.0, 507.0), Offset(134.2, 496.1), Offset(204.6, 390.6), Offset(275.0, 285.1), Offset(395.2, 219.5)],
    },
    'butterfly': {
      10: [Offset(744.5, 198.6), Offset(920.4, 277.2), Offset(618.8, 528.0), Offset(776.4, 826.9), Offset(546.5, 663.0), Offset(230.1, 813.5), Offset(405.2, 528.0), Offset(142.3, 440.7), Offset(139.7, 226.0), Offset(469.3, 386.9)],
      15: [Offset(744.5, 198.6), Offset(920.4, 277.2), Offset(859.0, 461.3), Offset(618.8, 528.0), Offset(796.8, 636.0), Offset(776.4, 826.9), Offset(546.5, 663.0), Offset(388.3, 738.3), Offset(230.1, 813.5), Offset(227.7, 635.2), Offset(405.2, 528.0), Offset(142.3, 440.7), Offset(139.7, 226.0), Offset(310.6, 209.9), Offset(469.3, 386.9)],
      20: [Offset(744.5, 198.6), Offset(920.4, 277.2), Offset(859.0, 461.3), Offset(618.8, 528.0), Offset(796.8, 636.0), Offset(776.4, 826.9), Offset(646.2, 805.9), Offset(546.5, 663.0), Offset(355.6, 820.4), Offset(230.1, 813.5), Offset(227.7, 635.2), Offset(405.2, 528.0), Offset(273.7, 484.4), Offset(142.3, 440.7), Offset(95.5, 337.6), Offset(139.7, 226.0), Offset(310.6, 209.9), Offset(469.3, 386.9), Offset(504.0, 280.2), Offset(554.7, 386.9)],
    },
    'car': {
      10: [Offset(426.0, 263.5), Offset(670.6, 263.7), Offset(908.3, 485.0), Offset(920.7, 628.0), Offset(765.5, 792.3), Offset(396.9, 687.0), Offset(268.1, 794.7), Offset(107.0, 648.1), Offset(116.2, 484.4), Offset(284.0, 463.0)],
      15: [Offset(426.0, 263.5), Offset(670.6, 263.7), Offset(792.6, 448.1), Offset(908.3, 485.0), Offset(920.7, 628.0), Offset(765.5, 792.3), Offset(666.2, 772.8), Offset(627.1, 687.0), Offset(396.9, 687.0), Offset(358.3, 772.3), Offset(268.1, 794.7), Offset(107.0, 648.1), Offset(116.2, 484.4), Offset(284.0, 463.0), Offset(333.0, 329.4)],
      20: [Offset(426.0, 263.5), Offset(548.3, 263.6), Offset(670.6, 263.7), Offset(747.4, 335.0), Offset(792.6, 448.1), Offset(908.3, 485.0), Offset(920.7, 628.0), Offset(765.5, 792.3), Offset(666.2, 772.8), Offset(627.1, 687.0), Offset(512.0, 687.0), Offset(396.9, 687.0), Offset(358.3, 772.3), Offset(268.1, 794.7), Offset(207.2, 757.8), Offset(183.1, 687.0), Offset(107.0, 648.1), Offset(116.2, 484.4), Offset(284.0, 463.0), Offset(333.0, 329.4)],
    },
    'carrot': {
      10: [Offset(509.7, 63.4), Offset(564.3, 237.2), Offset(770.0, 126.3), Offset(607.9, 324.3), Offset(675.8, 469.3), Offset(513.0, 926.9), Offset(348.2, 469.3), Offset(416.1, 324.3), Offset(255.8, 124.4), Offset(459.7, 237.2)],
      15: [Offset(509.7, 63.4), Offset(564.3, 237.2), Offset(662.2, 152.9), Offset(770.0, 126.3), Offset(725.0, 234.4), Offset(675.1, 362.9), Offset(675.8, 469.3), Offset(594.4, 698.1), Offset(513.0, 926.9), Offset(430.6, 698.1), Offset(348.2, 469.3), Offset(416.1, 324.3), Offset(299.0, 234.4), Offset(255.8, 124.4), Offset(459.7, 237.2)],
      20: [Offset(509.7, 63.4), Offset(556.2, 141.1), Offset(564.3, 237.2), Offset(662.2, 152.9), Offset(770.0, 126.3), Offset(725.0, 234.4), Offset(607.9, 324.3), Offset(675.1, 362.9), Offset(675.8, 469.3), Offset(617.6, 681.4), Offset(513.0, 926.9), Offset(406.4, 681.6), Offset(348.2, 469.3), Offset(348.9, 362.9), Offset(416.1, 324.3), Offset(299.0, 234.4), Offset(255.8, 124.4), Offset(361.8, 152.9), Offset(459.7, 237.2), Offset(467.8, 141.1)],
    },
    'chicken': {
      10: [Offset(364.9, 106.0), Offset(480.3, 216.5), Offset(466.5, 359.4), Offset(731.6, 427.9), Offset(925.2, 276.7), Offset(896.8, 524.8), Offset(608.7, 777.4), Offset(341.5, 723.7), Offset(217.2, 447.7), Offset(63.5, 382.4)],
      15: [Offset(364.9, 106.0), Offset(480.3, 216.5), Offset(466.5, 359.4), Offset(599.0, 393.7), Offset(731.6, 427.9), Offset(925.2, 276.7), Offset(896.8, 524.8), Offset(752.8, 651.1), Offset(608.7, 777.4), Offset(341.5, 723.7), Offset(268.6, 614.5), Offset(278.8, 497.0), Offset(63.5, 382.4), Offset(201.8, 322.2), Offset(225.0, 169.4)],
      20: [Offset(364.9, 106.0), Offset(480.3, 216.5), Offset(466.5, 359.4), Offset(609.3, 362.7), Offset(731.6, 427.9), Offset(828.4, 352.3), Offset(925.2, 276.7), Offset(933.7, 419.0), Offset(896.8, 524.8), Offset(807.7, 624.3), Offset(718.5, 723.7), Offset(608.7, 777.4), Offset(476.2, 782.6), Offset(341.5, 723.7), Offset(268.6, 614.5), Offset(278.8, 497.0), Offset(63.5, 382.4), Offset(201.8, 322.2), Offset(225.0, 169.4), Offset(314.5, 169.3)],
    },
    'corn': {
      10: [Offset(545.7, 140.6), Offset(603.8, 355.6), Offset(662.0, 570.5), Offset(756.5, 489.2), Offset(613.2, 877.9), Offset(475.6, 908.8), Offset(335.6, 802.4), Offset(286.2, 394.1), Offset(362.0, 570.5), Offset(410.3, 212.2)],
      15: [Offset(478.3, 140.6), Offset(601.8, 192.7), Offset(650.6, 310.8), Offset(662.0, 570.5), Offset(732.5, 393.2), Offset(756.5, 489.2), Offset(724.1, 736.1), Offset(613.2, 877.9), Offset(475.6, 908.8), Offset(335.6, 802.4), Offset(269.3, 619.2), Offset(286.2, 394.1), Offset(362.0, 570.5), Offset(386.2, 391.4), Offset(410.3, 212.2)],
      20: [Offset(478.3, 140.6), Offset(545.7, 140.6), Offset(601.8, 192.7), Offset(650.6, 310.8), Offset(656.3, 440.7), Offset(662.0, 570.5), Offset(732.5, 393.2), Offset(756.5, 489.2), Offset(754.7, 619.2), Offset(724.1, 736.1), Offset(666.2, 831.1), Offset(613.2, 877.9), Offset(475.6, 908.8), Offset(410.8, 877.9), Offset(335.6, 802.4), Offset(269.3, 619.2), Offset(286.2, 394.1), Offset(362.0, 570.5), Offset(366.9, 340.4), Offset(410.3, 212.2)],
    },
    'cow': {
      10: [Offset(349.5, 63.0), Offset(459.9, 198.7), Offset(677.7, 64.1), Offset(665.3, 248.0), Offset(910.9, 427.2), Offset(536.3, 846.2), Offset(289.9, 752.6), Offset(255.0, 469.2), Offset(113.9, 419.3), Offset(358.7, 248.0)],
      15: [Offset(349.5, 63.0), Offset(459.9, 198.7), Offset(564.1, 198.7), Offset(677.7, 64.1), Offset(665.3, 248.0), Offset(788.1, 337.6), Offset(910.9, 427.2), Offset(769.0, 469.2), Offset(723.7, 766.3), Offset(536.3, 846.2), Offset(289.9, 752.6), Offset(255.0, 469.2), Offset(113.9, 419.3), Offset(358.7, 248.0), Offset(318.4, 148.3)],
      20: [Offset(349.5, 63.0), Offset(459.9, 198.7), Offset(564.1, 198.7), Offset(677.7, 64.1), Offset(705.6, 148.3), Offset(665.3, 248.0), Offset(728.1, 320.4), Offset(866.3, 360.1), Offset(872.0, 474.9), Offset(769.0, 469.2), Offset(746.3, 617.8), Offset(723.7, 766.3), Offset(536.3, 846.2), Offset(397.4, 828.4), Offset(289.9, 752.6), Offset(255.0, 469.2), Offset(113.9, 419.3), Offset(236.3, 333.7), Offset(358.7, 248.0), Offset(318.4, 148.3)],
    },
    'elephant': {
      10: [Offset(266.2, 266.1), Offset(717.0, 299.8), Offset(881.2, 455.5), Offset(809.4, 874.2), Offset(693.0, 707.1), Offset(445.7, 872.3), Offset(320.1, 622.0), Offset(166.0, 865.7), Offset(153.8, 634.7), Offset(141.6, 403.7)],
      15: [Offset(266.2, 266.1), Offset(717.0, 299.8), Offset(823.4, 361.6), Offset(881.2, 455.5), Offset(809.4, 874.2), Offset(701.9, 861.3), Offset(693.0, 707.1), Offset(567.0, 714.1), Offset(558.1, 861.3), Offset(445.7, 872.3), Offset(423.0, 659.8), Offset(320.1, 622.0), Offset(275.8, 864.0), Offset(166.0, 865.7), Offset(141.6, 403.7)],
      20: [Offset(266.2, 266.1), Offset(478.3, 309.0), Offset(717.0, 299.8), Offset(823.4, 361.6), Offset(881.2, 455.5), Offset(845.3, 664.9), Offset(809.4, 874.2), Offset(701.9, 861.3), Offset(693.0, 707.1), Offset(567.0, 714.1), Offset(558.1, 861.3), Offset(445.7, 872.3), Offset(423.0, 659.8), Offset(320.1, 622.0), Offset(273.6, 733.2), Offset(275.8, 864.0), Offset(166.0, 865.7), Offset(135.4, 734.1), Offset(141.6, 403.7), Offset(179.8, 324.0)],
    },
    'fish': {
      10: [Offset(509.8, 202.7), Offset(748.1, 463.1), Offset(924.0, 324.2), Offset(925.9, 697.8), Offset(748.1, 560.9), Offset(592.3, 690.1), Offset(436.6, 819.4), Offset(290.6, 676.7), Offset(144.7, 534.0), Offset(181.0, 411.9)],
      15: [Offset(509.8, 202.7), Offset(748.1, 463.1), Offset(924.0, 324.2), Offset(925.9, 697.8), Offset(748.1, 560.9), Offset(685.6, 644.9), Offset(563.4, 704.3), Offset(517.8, 807.9), Offset(436.6, 819.4), Offset(378.0, 713.1), Offset(214.4, 644.9), Offset(144.7, 534.0), Offset(181.0, 411.9), Offset(330.3, 321.3), Offset(398.2, 215.4)],
      20: [Offset(442.8, 195.4), Offset(509.8, 202.7), Offset(569.4, 254.6), Offset(602.7, 332.5), Offset(703.4, 394.9), Offset(748.1, 463.1), Offset(924.0, 324.2), Offset(904.5, 512.0), Offset(925.9, 697.8), Offset(837.0, 629.3), Offset(748.1, 560.9), Offset(685.6, 644.9), Offset(563.4, 704.3), Offset(517.8, 807.9), Offset(436.6, 819.4), Offset(378.0, 713.1), Offset(214.4, 644.9), Offset(144.7, 534.0), Offset(181.0, 411.9), Offset(330.3, 321.3)],
    },
    'grapes': {
      10: [Offset(826.4, 202.3), Offset(685.2, 255.9), Offset(544.0, 309.6), Offset(804.0, 429.6), Offset(618.7, 627.4), Offset(433.5, 825.2), Offset(353.6, 582.7), Offset(273.7, 340.2), Offset(544.0, 268.9), Offset(685.2, 235.6)],
      15: [Offset(489.2, 159.5), Offset(544.0, 268.9), Offset(826.4, 202.3), Offset(738.7, 308.4), Offset(544.0, 309.6), Offset(607.0, 393.0), Offset(742.0, 336.2), Offset(804.0, 429.6), Offset(678.0, 641.7), Offset(552.0, 853.8), Offset(433.5, 825.2), Offset(432.9, 695.7), Offset(224.5, 460.0), Offset(273.7, 340.2), Offset(480.0, 333.2)],
      20: [Offset(489.2, 159.5), Offset(544.0, 268.9), Offset(659.4, 183.8), Offset(826.4, 202.3), Offset(738.7, 308.4), Offset(544.0, 309.6), Offset(607.0, 393.0), Offset(742.0, 336.2), Offset(804.0, 429.6), Offset(686.1, 530.7), Offset(701.1, 634.4), Offset(591.1, 695.7), Offset(552.0, 853.8), Offset(433.5, 825.2), Offset(432.9, 695.7), Offset(328.7, 577.8), Offset(224.5, 460.0), Offset(273.7, 340.2), Offset(417.0, 393.0), Offset(480.0, 333.2)],
    },
    'pumpkin': {
      10: [Offset(555.7, 157.4), Offset(732.5, 314.9), Offset(565.6, 326.3), Offset(816.7, 431.3), Offset(816.7, 768.7), Offset(703.7, 861.6), Offset(450.0, 805.1), Offset(196.3, 748.7), Offset(207.3, 431.3), Offset(459.6, 325.8)],
      15: [Offset(555.7, 157.4), Offset(608.5, 229.9), Offset(781.2, 230.5), Offset(732.5, 314.9), Offset(565.6, 326.3), Offset(722.8, 345.1), Offset(816.7, 431.3), Offset(861.0, 600.3), Offset(816.7, 768.7), Offset(703.7, 861.6), Offset(300.4, 854.6), Offset(196.3, 748.7), Offset(207.3, 431.3), Offset(301.2, 345.1), Offset(459.6, 325.8)],
      20: [Offset(555.7, 157.4), Offset(608.5, 229.9), Offset(806.0, 258.6), Offset(732.5, 314.9), Offset(565.6, 326.3), Offset(722.8, 345.1), Offset(816.7, 431.3), Offset(861.0, 600.3), Offset(816.7, 768.7), Offset(703.7, 861.6), Offset(597.8, 851.3), Offset(512.0, 887.0), Offset(406.2, 870.8), Offset(300.4, 854.6), Offset(196.3, 748.7), Offset(163.0, 599.7), Offset(207.3, 431.3), Offset(301.2, 345.1), Offset(459.6, 325.8), Offset(488.7, 221.6)],
    },
    'rocket': {
      10: [Offset(508.3, 84.0), Offset(639.2, 285.4), Offset(672.5, 531.8), Offset(859.4, 834.4), Offset(591.4, 727.0), Offset(512.3, 957.0), Offset(432.6, 727.0), Offset(165.5, 835.4), Offset(351.5, 531.8), Offset(389.9, 269.0)],
      15: [Offset(508.3, 84.0), Offset(590.5, 179.7), Offset(639.2, 285.4), Offset(672.5, 531.8), Offset(859.4, 834.4), Offset(591.4, 727.0), Offset(578.1, 824.8), Offset(512.3, 957.0), Offset(445.9, 824.8), Offset(432.6, 727.0), Offset(165.5, 835.4), Offset(258.5, 683.6), Offset(351.5, 531.8), Offset(389.9, 269.0), Offset(433.5, 179.7)],
      20: [Offset(508.3, 84.0), Offset(590.5, 179.7), Offset(639.2, 285.4), Offset(661.6, 397.7), Offset(672.5, 531.8), Offset(766.0, 683.1), Offset(859.4, 834.4), Offset(725.4, 780.7), Offset(591.4, 727.0), Offset(578.1, 824.8), Offset(512.3, 957.0), Offset(445.9, 824.8), Offset(403.2, 746.2), Offset(284.4, 790.8), Offset(165.5, 835.4), Offset(258.5, 683.6), Offset(351.5, 531.8), Offset(362.4, 397.7), Offset(389.9, 269.0), Offset(433.5, 179.7)],
    },
    'strawberry': {
      10: [Offset(511.3, 133.0), Offset(550.1, 292.1), Offset(768.4, 297.2), Offset(763.0, 634.0), Offset(514.4, 906.6), Offset(387.6, 770.0), Offset(260.7, 633.4), Offset(231.3, 461.6), Offset(313.9, 265.6), Offset(473.9, 292.1)],
      15: [Offset(511.3, 133.0), Offset(550.1, 292.1), Offset(659.8, 259.0), Offset(735.7, 337.7), Offset(792.7, 461.6), Offset(763.0, 634.0), Offset(638.7, 770.3), Offset(514.4, 906.6), Offset(369.4, 798.4), Offset(315.1, 715.9), Offset(260.7, 633.4), Offset(231.3, 461.6), Offset(288.3, 337.7), Offset(313.9, 265.6), Offset(473.9, 292.1)],
      20: [Offset(511.3, 133.0), Offset(554.5, 207.9), Offset(550.1, 292.1), Offset(659.8, 259.0), Offset(735.7, 337.7), Offset(792.7, 461.6), Offset(763.0, 634.0), Offset(708.8, 716.2), Offset(654.6, 798.4), Offset(514.4, 906.6), Offset(441.9, 852.5), Offset(369.4, 798.4), Offset(315.1, 715.9), Offset(260.7, 633.4), Offset(231.3, 461.6), Offset(255.3, 297.8), Offset(313.9, 265.6), Offset(400.1, 262.4), Offset(473.9, 292.1), Offset(469.5, 207.9)],
    },
    'tomato': {
      10: [Offset(499.1, 143.1), Offset(617.3, 183.0), Offset(599.5, 296.5), Offset(790.9, 428.8), Offset(849.0, 589.6), Offset(750.1, 793.1), Offset(512.3, 877.0), Offset(273.9, 793.1), Offset(175.0, 590.4), Offset(337.0, 366.7)],
      15: [Offset(499.1, 143.1), Offset(544.0, 215.9), Offset(617.3, 183.0), Offset(599.5, 296.5), Offset(790.9, 428.8), Offset(849.0, 589.6), Offset(750.1, 793.1), Offset(512.3, 877.0), Offset(393.1, 835.0), Offset(273.9, 793.1), Offset(175.0, 590.4), Offset(233.1, 428.8), Offset(424.5, 296.5), Offset(406.3, 183.5), Offset(480.0, 215.9)],
      20: [Offset(540.8, 151.5), Offset(544.0, 215.9), Offset(617.3, 183.0), Offset(599.5, 296.5), Offset(790.9, 428.8), Offset(849.0, 589.6), Offset(822.5, 701.7), Offset(750.1, 793.1), Offset(642.5, 854.7), Offset(512.3, 877.0), Offset(381.5, 854.7), Offset(273.9, 793.1), Offset(201.5, 701.7), Offset(175.0, 590.4), Offset(190.1, 504.7), Offset(233.1, 428.8), Offset(328.8, 362.7), Offset(424.5, 296.5), Offset(406.3, 183.5), Offset(480.0, 215.9)],
    },
    'tractor': {
      10: [Offset(524.9, 230.5), Offset(790.0, 235.5), Offset(793.2, 546.5), Offset(796.4, 857.4), Offset(368.2, 667.0), Offset(379.6, 828.5), Offset(230.4, 881.0), Offset(269.2, 286.1), Offset(327.0, 453.0), Offset(513.0, 453.0)],
      15: [Offset(524.9, 230.5), Offset(790.0, 235.5), Offset(872.0, 714.6), Offset(796.4, 857.4), Offset(632.7, 873.3), Offset(534.9, 667.0), Offset(368.2, 667.0), Offset(379.6, 828.5), Offset(230.4, 881.0), Offset(140.8, 781.9), Offset(164.3, 477.9), Offset(263.0, 453.0), Offset(269.2, 286.1), Offset(327.0, 453.0), Offset(513.0, 453.0)],
      20: [Offset(524.9, 230.5), Offset(790.0, 235.5), Offset(793.5, 404.3), Offset(797.0, 573.0), Offset(872.0, 714.6), Offset(796.4, 857.4), Offset(632.7, 873.3), Offset(541.7, 782.3), Offset(534.9, 667.0), Offset(368.2, 667.0), Offset(401.3, 741.9), Offset(379.6, 828.5), Offset(230.4, 881.0), Offset(140.8, 781.9), Offset(177.2, 661.2), Offset(164.3, 477.9), Offset(263.0, 453.0), Offset(325.9, 293.1), Offset(327.0, 453.0), Offset(513.0, 453.0)],
    },
    'train': {
      10: [Offset(508.3, 179.5), Offset(825.5, 183.3), Offset(780.3, 480.3), Offset(735.1, 777.3), Offset(550.5, 677.0), Offset(360.5, 677.0), Offset(262.8, 795.3), Offset(254.1, 540.0), Offset(245.5, 284.7), Offset(533.0, 413.0)],
      15: [Offset(508.3, 179.5), Offset(825.5, 183.3), Offset(780.3, 480.3), Offset(735.1, 777.3), Offset(638.2, 786.3), Offset(550.5, 677.0), Offset(444.5, 793.2), Offset(360.5, 677.0), Offset(262.8, 795.3), Offset(163.5, 442.2), Offset(260.5, 413.0), Offset(245.5, 284.7), Offset(375.1, 285.2), Offset(359.5, 413.0), Offset(533.0, 413.0)],
      20: [Offset(508.3, 179.5), Offset(825.5, 183.3), Offset(811.0, 419.6), Offset(796.6, 656.0), Offset(735.1, 777.3), Offset(638.2, 786.3), Offset(550.5, 677.0), Offset(531.8, 771.3), Offset(444.5, 793.2), Offset(360.5, 677.0), Offset(346.9, 765.6), Offset(262.8, 795.3), Offset(203.3, 751.2), Offset(163.6, 648.3), Offset(163.5, 442.2), Offset(260.5, 413.0), Offset(245.5, 284.7), Offset(375.1, 285.2), Offset(359.5, 413.0), Offset(533.0, 413.0)],
    },
    'turtle': {
      10: [Offset(539.7, 263.0), Offset(952.0, 611.6), Offset(756.9, 627.0), Offset(710.2, 787.0), Offset(623.1, 627.0), Offset(436.9, 627.0), Offset(350.0, 787.0), Offset(94.1, 615.4), Offset(87.7, 471.7), Offset(254.9, 475.1)],
      15: [Offset(539.7, 263.0), Offset(720.6, 332.7), Offset(836.3, 472.1), Offset(952.0, 611.6), Offset(756.9, 627.0), Offset(629.4, 767.6), Offset(623.1, 627.0), Offset(436.9, 627.0), Offset(350.0, 787.0), Offset(303.1, 627.0), Offset(198.6, 621.2), Offset(94.1, 615.4), Offset(87.7, 471.7), Offset(254.9, 475.1), Offset(351.5, 329.2)],
      20: [Offset(539.7, 263.0), Offset(720.6, 332.7), Offset(770.0, 431.0), Offset(819.4, 529.3), Offset(952.0, 611.6), Offset(756.9, 627.0), Offset(710.2, 787.0), Offset(629.4, 767.6), Offset(623.1, 627.0), Offset(436.9, 627.0), Offset(430.6, 767.6), Offset(305.8, 759.4), Offset(303.1, 627.0), Offset(198.6, 621.2), Offset(94.1, 615.4), Offset(87.7, 471.7), Offset(170.4, 433.0), Offset(254.9, 475.1), Offset(351.5, 329.2), Offset(445.6, 296.1)],
    },
  };
}
