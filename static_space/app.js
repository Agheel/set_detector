// Set Detector — 100% On-Device Web AI (YOLOv11 ONNX Runtime Web + GF(3)^4 Solver)
(() => {
  const SET_PALETTE = ['#06B6D4', '#F43F5E', '#F59E0B'];
  const SET_TINTS = ['rgba(6,182,212,0.12)', 'rgba(244,63,94,0.12)', 'rgba(245,158,11,0.12)'];
  const COLOR_HEX = { 1: '#B83F58', 2: '#33785B', 3: '#725197' }; // 1:Red, 2:Green, 3:Purple

  // Exact 82 class names from trained Roboflow YOLOv11 best.pt / best.onnx
  const YOLO_LABELS = [
    'GDE1','GDE2','GDE3','GDL1','GDL2','GDL3','GDS1','GDS2','GDS3',
    'GPE1','GPE2','GPE3','GPL1','GPL2','GPL3','GPS1','GPS2','GPS3','GPTS1',
    'GTE1','GTE2','GTE3','GTL1','GTL2','GTL3','GTS1','GTS2','GTS3',
    'PDE1','PDE2','PDE3','PDL1','PDL2','PDL3','PDS1','PDS2','PDS3',
    'PPE1','PPE2','PPE3','PPL1','PPL2','PPL3','PPS1','PPS2','PPS3',
    'PTE1','PTE2','PTE3','PTL1','PTL2','PTL3','PTS1','PTS2','PTS3',
    'RDE1','RDE2','RDE3','RDL1','RDL2','RDL3','RDS1','RDS2','RDS3',
    'RPE1','RPE2','RPE3','RPL1','RPL2','RPL3','RPS1','RPS2','RPS3',
    'RTE1','RTE2','RTE3','RTL1','RTL2','RTL3','RTS1','RTS2','RTS3'
  ];

  function parseCompactLabel(code) {
    const lower = String(code).trim().toLowerCase();
    if (lower.length !== 4 && lower.length !== 5) return null;
    const colorMap = { r: 1, g: 2, p: 3 };
    const shapeMap = { p: 1, o: 1, d: 2, t: 3, s: 3 };
    const shadingMap = { s: 1, l: 2, e: 3 };
    const color = colorMap[lower[0]];
    const shape = shapeMap[lower[lower.length - 3]];
    const shading = shadingMap[lower[lower.length - 2]];
    const number = parseInt(lower[lower.length - 1], 10);
    if (!color || !shape || !shading || !(number >= 1 && number <= 3)) return null;
    return { number, shape, color, shading };
  }

  // Default Figma 12-card preset (yields 3 SETs: 01·02·05, 04·11·12, 06·10·12)
  function getFigmaPresetCards() {
    return [
      { number: 1, shape: 3, color: 3, shading: 1 }, // 01
      { number: 2, shape: 2, color: 2, shading: 2 }, // 02
      { number: 2, shape: 1, color: 1, shading: 1 }, // 03
      { number: 3, shape: 1, color: 3, shading: 1 }, // 04
      { number: 3, shape: 1, color: 1, shading: 3 }, // 05
      { number: 3, shape: 1, color: 1, shading: 3 }, // 06
      { number: 1, shape: 2, color: 1, shading: 3 }, // 07
      { number: 3, shape: 3, color: 3, shading: 2 }, // 08
      { number: 3, shape: 3, color: 2, shading: 3 }, // 09
      { number: 2, shape: 1, color: 2, shading: 3 }, // 10
      { number: 2, shape: 1, color: 3, shading: 2 }, // 11
      { number: 1, shape: 1, color: 3, shading: 3 }, // 12
    ];
  }

  // GF(3)^4 Modulo 3 SET Solver
  function isSet(a, b, c) {
    return (
      (a.number + b.number + c.number) % 3 === 0 &&
      (a.shape + b.shape + c.shape) % 3 === 0 &&
      (a.color + b.color + c.color) % 3 === 0 &&
      (a.shading + b.shading + c.shading) % 3 === 0
    );
  }

  function findSets(cards) {
    const sets = [];
    for (let i = 0; i < cards.length; i++) {
      for (let j = i + 1; j < cards.length; j++) {
        for (let k = j + 1; k < cards.length; k++) {
          if (isSet(cards[i], cards[j], cards[k])) {
            sets.push({ indices: [i, j, k], cards: [cards[i], cards[j], cards[k]] });
          }
        }
      }
    }
    return sets;
  }

  function getAttributeRules(cards) {
    if (!cards || cards.length < 3) return ['모양 일치', '색상 다름', '개수 다름', '채움 일치'];
    const sameShape = cards[0].shape === cards[1].shape && cards[1].shape === cards[2].shape;
    const sameColor = cards[0].color === cards[1].color && cards[1].color === cards[2].color;
    const sameNumber = cards[0].number === cards[1].number && cards[1].number === cards[2].number;
    const sameShading = cards[0].shading === cards[1].shading && cards[1].shading === cards[2].shading;
    return [
      sameShape ? '모양 일치' : '모양 다름',
      sameColor ? '색상 일치' : '색상 다름',
      sameNumber ? '개수 일치' : '개수 다름',
      sameShading ? '채움 일치' : '채움 다름',
    ];
  }

  // Render SVG symbol for a card
  let patternSeq = 0;
  function createSymbolSvg(shape, colorCode, shading) {
    const stroke = COLOR_HEX[colorCode] || '#B83F58';
    const pid = `stripe-${++patternSeq}`;
    let fillAttr = 'none';
    let defs = '';
    if (shading === 1) {
      fillAttr = stroke;
    } else if (shading === 2) {
      defs = `<defs><pattern id="${pid}" width="4" height="4" patternUnits="userSpaceOnUse"><line x1="0" y1="2" x2="4" y2="2" stroke="${stroke}" stroke-width="1.3"/></pattern></defs>`;
      fillAttr = `url(#${pid})`;
    }

    let shapeEl = '';
    if (shape === 1) {
      shapeEl = `<rect x="2" y="2" width="12" height="32" rx="6" fill="${fillAttr}" stroke="${stroke}" stroke-width="1.8"/>`;
    } else if (shape === 2) {
      shapeEl = `<polygon points="8,2 14.5,18 8,34 1.5,18" fill="${fillAttr}" stroke="${stroke}" stroke-width="1.8" stroke-linejoin="round"/>`;
    } else {
      shapeEl = `<path d="M4,4 C13,1 15,12 10,18 C5,24 14,30 11,33 C3,36 1,24 6,17 C10,11 2,7 4,4 Z" fill="${fillAttr}" stroke="${stroke}" stroke-width="1.8"/>`;
    }
    return `<svg width="16" height="36" viewBox="0 0 16 36">${defs}${shapeEl}</svg>`;
  }

  function createPlayingCardHtml(card, options = {}) {
    const {
      badge,
      highlightColor,
      dimmed,
      width = 88,
      height = 80,
      cardIndex = null,
      editable = false,
    } = options;
    const symbols = Array.from({ length: card.number }, () =>
      createSymbolSvg(card.shape, card.color, card.shading)
    ).join('');
    const bboxStyle = highlightColor
      ? `border: 2.2px solid ${highlightColor};`
      : badge
      ? `border: 1.3px solid rgba(248,250,252,0.7);`
      : `border: none;`;
    const badgeStyle = highlightColor
      ? `background:${highlightColor};border-color:${highlightColor};color:#0F172A;`
      : '';
    const dataAttr =
      cardIndex !== null ? `data-card-index="${cardIndex}" title="터치하여 카드 속성 수정"` : '';

    return `
      <div class="card-slot" ${dataAttr} style="width:${width + 8}px;height:${height + 8}px;">
        ${badge || highlightColor ? `<div class="card-bbox" style="width:${width + 8}px;height:${height + 8}px;${bboxStyle}"></div>` : ''}
        <div class="playing-card" style="width:${width}px;height:${height}px;">${symbols}</div>
        ${badge ? `<div class="card-badge" style="${badgeStyle}">${badge}</div>` : ''}
        ${editable ? `<div class="card-edit-hint">✎</div>` : ''}
        ${dimmed ? `<div class="card-dim" style="width:${width + 12}px;height:${height + 12}px;"></div>` : ''}
      </div>
    `;
  }

  function createAddCardSlotHtml() {
    return `
      <div class="card-slot">
        <button type="button" class="add-card-slot" data-add-card="true">
          <span style="font-size:18px;line-height:1;">＋</span>
          <span>카드 추가</span>
        </button>
      </div>
    `;
  }

  // App State
  let currentCards = getFigmaPresetCards();
  let currentSets = findSets(currentCards);
  let selectedSetIndex = 0;
  let twoCardHintOnly = false;
  let ortSession = null;
  let editingCardIndex = 0;
  let draftCard = { number: 1, shape: 1, color: 1, shading: 1 };

  // Render Screen 01 Illustration (#8:10930)
  function renderOnboardingIllustration() {
    const container = document.getElementById('onboarding-illustration');
    if (!container) return;
    const c1 = createPlayingCardHtml({ number: 1, shape: 3, color: 3, shading: 1 }, { width: 88, height: 124 });
    const c2 = createPlayingCardHtml({ number: 2, shape: 2, color: 2, shading: 2 }, { width: 88, height: 124 });
    const c3 = createPlayingCardHtml({ number: 3, shape: 1, color: 1, shading: 3 }, { width: 88, height: 124 });
    container.innerHTML = `
      <svg width="100%" height="240" viewBox="0 0 345 240" style="position:absolute;inset:0;pointer-events:none;">
        <g stroke="rgba(51,65,85,0.33)" stroke-width="1">
          <line x1="0" y1="0" x2="0" y2="240"/><line x1="64" y1="0" x2="64" y2="240"/>
          <line x1="128" y1="0" x2="128" y2="240"/><line x1="192" y1="0" x2="192" y2="240"/>
          <line x1="256" y1="0" x2="256" y2="240"/><line x1="320" y1="0" x2="320" y2="240"/>
          <line x1="0" y1="16" x2="345" y2="16"/><line x1="0" y1="80" x2="345" y2="80"/>
          <line x1="0" y1="144" x2="345" y2="144"/><line x1="0" y1="208" x2="345" y2="208"/>
        </g>
      </svg>
      <div style="position:absolute;left:0;top:48px;">${c1}</div>
      <div style="position:absolute;left:128px;top:0px;">${c2}</div>
      <div style="position:absolute;left:256px;top:80px;">${c3}</div>
      <svg width="100%" height="240" viewBox="0 0 345 240" style="position:absolute;inset:0;pointer-events:none;z-index:5;">
        <line x1="48" y1="114" x2="176" y2="66" stroke="#06B6D4" stroke-width="2"/>
        <line x1="176" y1="66" x2="304" y2="146" stroke="#F43F5E" stroke-width="2"/>
        <line x1="48" y1="114" x2="304" y2="146" stroke="#F59E0B" stroke-width="2"/>
        <circle cx="48" cy="114" r="4" fill="#06B6D4" stroke="#0F172A" stroke-width="2"/>
        <circle cx="176" cy="66" r="4" fill="#F43F5E" stroke="#0F172A" stroke-width="2"/>
        <circle cx="304" cy="146" r="4" fill="#F59E0B" stroke="#0F172A" stroke-width="2"/>
      </svg>
      <div class="illus-annotation">
        <span style="color:var(--text-secondary);">VISION / FOUR ATTRIBUTES</span>
        <span style="color:var(--cyan-accent);font-weight:600;">SET VERIFIED ✓</span>
      </div>
    `;
  }

  function createGuideSlotHtml(idx) {
    const label = String(idx + 1).padStart(2, '0');
    return `
      <div class="guide-slot">
        <svg class="guide-corners" viewBox="0 0 90 82" fill="none">
          <path d="M1 15 V9 Q1 1 9 1 H15" stroke="#06B6D4" stroke-width="1.8" stroke-linecap="round"/>
          <path d="M75 1 H81 Q89 1 89 9 V15" stroke="#06B6D4" stroke-width="1.8" stroke-linecap="round"/>
          <path d="M1 67 V73 Q1 81 9 81 H15" stroke="#06B6D4" stroke-width="1.8" stroke-linecap="round"/>
          <path d="M75 81 H81 Q89 81 89 73 V67" stroke="#06B6D4" stroke-width="1.8" stroke-linecap="round"/>
        </svg>
        <span class="guide-slot-num">${label}</span>
        <span class="guide-slot-cross"></span>
      </div>
    `;
  }

  function renderAllBoards() {
    // 02 Viewfinder: 12 transparent registration guide slots (3x4) so camera feed is visible
    const vfGrid = document.getElementById('viewfinder-grid');
    if (vfGrid) {
      vfGrid.innerHTML = Array.from({ length: 12 }, (_, idx) =>
        createGuideSlotHtml(idx)
      ).join('');
    }
    const vfCount = document.getElementById('viewfinder-card-count');
    if (vfCount) vfCount.textContent = `${currentCards.length} / 12 CARDS`;

    // 03 Detection Result (existence only, no triangle spoilers)
    const resGrid = document.getElementById('result-grid');
    if (resGrid) {
      const items = currentCards
        .slice(0, 12)
        .map((c, idx) =>
          createPlayingCardHtml(c, {
            badge: String(idx + 1).padStart(2, '0'),
            cardIndex: idx,
            editable: true,
          })
        );
      if (items.length < 12) items.push(createAddCardSlotHtml());
      resGrid.innerHTML = items.join('');
    }
    const resLine = document.getElementById('result-summary-line');
    if (resLine) resLine.textContent = `${currentCards.length}장 분석 완료 · 세트 존재 여부 확인`;

    // 05 Empty Set
    const emptyGrid = document.getElementById('empty-grid');
    if (emptyGrid) {
      const items = currentCards
        .slice(0, 12)
        .map((c, idx) =>
          createPlayingCardHtml(c, {
            badge: String(idx + 1).padStart(2, '0'),
            cardIndex: idx,
            editable: true,
          })
        );
      if (items.length < 12) items.push(createAddCardSlotHtml());
      emptyGrid.innerHTML = items.join('');
    }
    const emptyLine = document.getElementById('empty-summary-line');
    if (emptyLine) emptyLine.textContent = `${currentCards.length}장 인식 완료 · 가능한 조합을 모두 확인했어요`;

    renderDetailScreen();
  }

  function renderDetailScreen() {
    const detailGrid = document.getElementById('detail-grid');
    const svgOverlay = document.getElementById('detail-svg-overlay');
    if (!detailGrid || !svgOverlay) return;

    if (!currentSets.length) {
      detailGrid.innerHTML = '';
      svgOverlay.innerHTML = '';
      return;
    }

    const safeIdx = Math.max(0, Math.min(selectedSetIndex, currentSets.length - 1));
    const activeSet = currentSets[safeIdx];
    const color = SET_PALETTE[safeIdx % SET_PALETTE.length];
    const tint = SET_TINTS[safeIdx % SET_TINTS.length];
    const visibleIndices = twoCardHintOnly
      ? new Set(activeSet.indices.slice(0, 2))
      : new Set(activeSet.indices);

    detailGrid.innerHTML = currentCards
      .slice(0, 12)
      .map((c, idx) => {
        const focused = visibleIndices.has(idx);
        return createPlayingCardHtml(c, {
          badge: String(idx + 1).padStart(2, '0'),
          highlightColor: focused ? color : null,
          dimmed: !focused,
          cardIndex: idx,
          editable: true,
        });
      })
      .join('');

    // Draw triangle on SVG overlay when all 3 cards are shown
    const viewport = document.getElementById('detail-board-viewport');
    const w = viewport ? viewport.clientWidth || 345 : 345;
    const h = viewport ? viewport.clientHeight || 368 : 368;
    svgOverlay.setAttribute('viewBox', `0 0 ${w} ${h}`);

    if (!twoCardHintOnly && activeSet.indices.length === 3) {
      const pts = activeSet.indices.map((idx) => {
        const col = idx % 3;
        const row = Math.floor(idx / 3);
        return [(col + 0.5) * (w / 3), (row + 0.5) * (h / 4)];
      });
      const polyPts = pts.map((p) => p.join(',')).join(' ');
      svgOverlay.innerHTML = `
        <polygon points="${polyPts}" fill="${color}" fill-opacity="0.14" stroke="${color}" stroke-width="2.4" stroke-linejoin="round"/>
        ${pts.map(([x, y]) => `<circle cx="${x}" cy="${y}" r="4.5" fill="${color}" stroke="#0F172A" stroke-width="2"/>`).join('')}
      `;
    } else {
      svgOverlay.innerHTML = '';
    }

    // Update Bottomsheet
    document.getElementById('detail-set-title').textContent = `세트 ${String(safeIdx + 1).padStart(2, '0')}`;
    const counterEl = document.getElementById('detail-set-counter');
    counterEl.textContent = `${safeIdx + 1} / ${currentSets.length}`;
    counterEl.style.color = color;

    document.getElementById('detail-guide-text').textContent = twoCardHintOnly
      ? '힌트 2장과 세트를 이루는 나머지 1장을 찾아보세요'
      : '강조된 3장의 카드를 함께 확인해보세요';

    document.getElementById('detail-card-chips').innerHTML = activeSet.indices
      .map((cardIdx, i) => {
        const label = twoCardHintOnly && i === 2 ? '??' : String(cardIdx + 1).padStart(2, '0');
        return `<span class="num-chip" style="background:${tint};border:0.6px solid ${color};color:${color};">${label}</span>`;
      })
      .join('');

    document.getElementById('detail-rule-chips').innerHTML = getAttributeRules(activeSet.cards)
      .map((rule) => `<span class="rule-chip">${rule}</span>`)
      .join('');

    document.getElementById('detail-dots').innerHTML = currentSets
      .map((_, idx) => {
        const active = idx === safeIdx;
        return `<span style="width:${active ? 18 : 5}px;height:4px;border-radius:2px;background:${active ? color : '#334155'};transition:width 0.2s;"></span>`;
      })
      .join('');
  }

  function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach((el) => el.classList.remove('active'));
    const target = document.getElementById(screenId);
    if (target) target.classList.add('active');
    if (screenId === 'screen-04') {
      requestAnimationFrame(renderDetailScreen);
    }
  }

  // Load YOLOv11 ONNX model if present
  async function initOnnxModel() {
    if (typeof ort === 'undefined') return;
    try {
      ortSession = await ort.InferenceSession.create('./best.onnx', {
        executionProviders: ['wasm'],
      });
      const badge = document.getElementById('ai-engine-badge');
      if (badge) badge.innerHTML = '⚡ 기기 내 분석 (YOLOv11 ONNX 활성)';
    } catch (_) {
      // Fallback to preset/manual solver if best.onnx is not yet loaded
    }
  }

  // 4-Stage SET Card Preprocessing:
  // 1) Card-White Auto White Balance (92nd percentile RGB reference, clamped [0.75, 1.35])
  // 2) Hue-preserving mild contrast stretch around midpoint (128.0)
  // 3) 3x3 Unsharp Mask to sharpen fine Striped (L) vs Solid (S) / Open (E) card interiors
  function preprocessCanvasRgba(rgba, size) {
    const area = size * size;
    const rSamples = [];
    const gSamples = [];
    const bSamples = [];
    const step = 16; // Fast subsampling for 92nd percentile estimation
    for (let i = 0; i < area; i += step) {
      const idx = i * 4;
      rSamples.push(rgba[idx]);
      gSamples.push(rgba[idx + 1]);
      bSamples.push(rgba[idx + 2]);
    }
    rSamples.sort((a, b) => a - b);
    gSamples.sort((a, b) => a - b);
    bSamples.sort((a, b) => a - b);
    const p92 = Math.floor(rSamples.length * 0.92);
    const refR = Math.max(30, rSamples[p92] || 200);
    const refG = Math.max(30, gSamples[p92] || 200);
    const refB = Math.max(30, bSamples[p92] || 200);
    const targetLum = (refR + refG + refB) / 3.0;
    const gainR = Math.min(1.35, Math.max(0.75, targetLum / refR));
    const gainG = Math.min(1.35, Math.max(0.75, targetLum / refG));
    const gainB = Math.min(1.35, Math.max(0.75, targetLum / refB));

    const rPlane = new Float32Array(area);
    const gPlane = new Float32Array(area);
    const bPlane = new Float32Array(area);
    for (let i = 0; i < area; i++) {
      const idx = i * 4;
      rPlane[i] = (rgba[idx] * gainR - 128.0) * 1.08 + 128.0;
      gPlane[i] = (rgba[idx + 1] * gainG - 128.0) * 1.08 + 128.0;
      bPlane[i] = (rgba[idx + 2] * gainB - 128.0) * 1.08 + 128.0;
    }

    // 3x3 Unsharp Mask -> normalized [0, 1] CHW tensor
    const floatData = new Float32Array(3 * area);
    const planes = [rPlane, gPlane, bPlane];
    for (let c = 0; c < 3; c++) {
      const src = planes[c];
      const offset = c * area;
      for (let y = 0; y < size; y++) {
        const y0 = Math.max(0, y - 1) * size;
        const y1 = y * size;
        const y2 = Math.min(size - 1, y + 1) * size;
        for (let x = 0; x < size; x++) {
          const x0 = Math.max(0, x - 1);
          const x2 = Math.min(size - 1, x + 1);
          const blur =
            (src[y0 + x0] + src[y0 + x] + src[y0 + x2] +
             src[y1 + x0] + src[y1 + x] + src[y1 + x2] +
             src[y2 + x0] + src[y2 + x] + src[y2 + x2]) / 9.0;
          const val = src[y1 + x] * 1.25 - blur * 0.25;
          floatData[offset + y1 + x] = Math.min(255, Math.max(0, val)) / 255.0;
        }
      }
    }
    return floatData;
  }

  async function runSingleYoloPass(sourceEl, cropRect) {
    const size = 640;
    const sx = cropRect.x;
    const sy = cropRect.y;
    const sw = cropRect.w;
    const sh = cropRect.h;
    const scale = Math.min(size / sw, size / sh);
    const drawW = Math.round(sw * scale);
    const drawH = Math.round(sh * scale);
    const padX = Math.floor((size - drawW) / 2);
    const padY = Math.floor((size - drawH) / 2);

    const canvas = document.createElement('canvas');
    canvas.width = size;
    canvas.height = size;
    const ctx = canvas.getContext('2d');
    ctx.fillStyle = '#727272';
    ctx.fillRect(0, 0, size, size);
    ctx.drawImage(sourceEl, sx, sy, sw, sh, padX, padY, drawW, drawH);
    const { data } = ctx.getImageData(0, 0, size, size);

    const floatData = preprocessCanvasRgba(data, size);
    const inputTensor = new ort.Tensor('float32', floatData, [1, 3, size, size]);
    const inputName = ortSession.inputNames[0];
    const outputs = await ortSession.run({ [inputName]: inputTensor });
    const outputTensor = outputs[ortSession.outputNames[0]];
    const out = outputTensor.data;
    const [, channels, numAnchors] = outputTensor.dims; // [1, 86, 8400]
    const numClasses = channels - 4;

    const candidates = [];
    for (let a = 0; a < numAnchors; a++) {
      let bestCls = 0;
      let bestScore = 0;
      for (let c = 0; c < numClasses; c++) {
        const score = out[(4 + c) * numAnchors + a];
        if (score > bestScore) {
          bestScore = score;
          bestCls = c;
        }
      }
      if (bestScore >= 0.25) {
        const cx = out[0 * numAnchors + a];
        const cy = out[1 * numAnchors + a];
        const w = out[2 * numAnchors + a];
        const h = out[3 * numAnchors + a];
        candidates.push({
          x1: cx - w / 2,
          y1: cy - h / 2,
          x2: cx + w / 2,
          y2: cy + h / 2,
          cx,
          cy,
          score: bestScore,
          cls: bestCls,
        });
      }
    }

    // Non-Maximum Suppression (NMS)
    candidates.sort((a, b) => b.score - a.score);
    const picked = [];
    for (const box of candidates) {
      let keep = true;
      for (const prev of picked) {
        const xx1 = Math.max(box.x1, prev.x1);
        const yy1 = Math.max(box.y1, prev.y1);
        const xx2 = Math.min(box.x2, prev.x2);
        const yy2 = Math.min(box.y2, prev.y2);
        const inter = Math.max(0, xx2 - xx1) * Math.max(0, yy2 - yy1);
        const areaA = (box.x2 - box.x1) * (box.y2 - box.y1);
        const areaB = (prev.x2 - prev.x1) * (prev.y2 - prev.y1);
        if (inter / (areaA + areaB - inter + 1e-6) > 0.45) {
          keep = false;
          break;
        }
      }
      if (keep) picked.push(box);
      if (picked.length >= 12) break;
    }

    // Sort top-to-bottom (4 rows), left-to-right (3 cols)
    picked.sort((a, b) => (Math.abs(a.cy - b.cy) > 55 ? a.cy - b.cy : a.cx - b.cx));

    const cards = [];
    let scoreSum = 0;
    for (const item of picked) {
      const label = YOLO_LABELS[item.cls];
      const parsed = parseCompactLabel(label);
      if (parsed) {
        cards.push(parsed);
        scoreSum += item.score;
      }
    }
    return { cards, scoreSum };
  }

  // Dual-Pass YOLOv11 ONNX Inference (Pass 1: 3x4 Guide ROI Crop, Pass 2: Full Frame Letterbox)
  async function runYoloOnnxInference(sourceEl) {
    if (!ortSession) return null;
    const srcW = sourceEl.videoWidth || sourceEl.naturalWidth || 640;
    const srcH = sourceEl.videoHeight || sourceEl.naturalHeight || 640;

    // Pass 1: Central 3x4 Guide ROI crop on portrait frames (doubles effective card resolution)
    let bestResult = { cards: [], scoreSum: 0 };
    if (srcH > srcW * 1.15) {
      const roiRect = {
        x: Math.round(srcW * 0.05),
        y: Math.round(srcH * 0.14),
        w: Math.round(srcW * 0.90),
        h: Math.round(srcH * 0.66),
      };
      bestResult = await runSingleYoloPass(sourceEl, roiRect);
    }

    // Pass 2: Full-frame letterbox fallback if fewer than 12 cards were found in ROI
    if (bestResult.cards.length < 12) {
      const fullResult = await runSingleYoloPass(sourceEl, { x: 0, y: 0, w: srcW, h: srcH });
      if (
        fullResult.cards.length > bestResult.cards.length ||
        (fullResult.cards.length === bestResult.cards.length &&
          fullResult.scoreSum > bestResult.scoreSum)
      ) {
        bestResult = fullResult;
      }
    }

    return bestResult.cards.length >= 3 ? bestResult.cards : null;
  }

  async function triggerCaptureAndAnalyze(sourceEl) {
    if (sourceEl && ortSession) {
      try {
        const detectedCards = await runYoloOnnxInference(sourceEl);
        if (!detectedCards) {
          showScreen('screen-05b');
          return;
        }
        currentCards = detectedCards;
      } catch (_) {
        showScreen('screen-05b');
        return;
      }
    }
    currentSets = findSets(currentCards);
    selectedSetIndex = 0;
    renderAllBoards();
    showScreen(currentSets.length > 0 ? 'screen-03' : 'screen-05');
  }

  // Event bindings
  document.addEventListener('DOMContentLoaded', () => {
    renderOnboardingIllustration();
    renderAllBoards();
    initOnnxModel();

    document.querySelectorAll('[data-go]').forEach((btn) => {
      btn.addEventListener('click', () => showScreen(btn.getAttribute('data-go')));
    });

    document.getElementById('btn-start-camera').addEventListener('click', async () => {
      showScreen('screen-02');
      const video = document.getElementById('camera-video');
      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        try {
          const stream = await navigator.mediaDevices.getUserMedia({
            video: { facingMode: 'environment' },
            audio: false,
          });
          video.srcObject = stream;
          video.classList.add('active');
        } catch (_) {
          // Camera unavailable or denied -> keep interactive tabletop preview
        }
      }
    });

    document.getElementById('btn-shutter').addEventListener('click', () => {
      const video = document.getElementById('camera-video');
      const src = video && video.classList.contains('active') ? video : null;
      triggerCaptureAndAnalyze(src);
    });

    const albumInput = document.getElementById('album-file-input');
    document.getElementById('btn-album-import').addEventListener('click', () => {
      albumInput.click();
    });
    albumInput.addEventListener('change', (e) => {
      const file = e.target.files && e.target.files[0];
      if (!file) return;
      const img = new Image();
      img.onload = () => triggerCaptureAndAnalyze(img);
      img.src = URL.createObjectURL(file);
    });

    document.getElementById('mode-auto').addEventListener('click', () => {
      document.getElementById('mode-auto').classList.add('active');
      document.getElementById('mode-manual').classList.remove('active');
      document.getElementById('capture-guide-sub').textContent = '화면이 안정되면 자동으로 촬영합니다.';
      document.getElementById('shutter-caption').textContent = '자동 촬영 대기';
    });

    document.getElementById('mode-manual').addEventListener('click', () => {
      document.getElementById('mode-manual').classList.add('active');
      document.getElementById('mode-auto').classList.remove('active');
      document.getElementById('capture-guide-sub').textContent = '셔터 버튼을 눌러 카드를 촬영하세요.';
      document.getElementById('shutter-caption').textContent = '탭하여 촬영';
    });

    document.getElementById('btn-prev-set').addEventListener('click', () => {
      if (selectedSetIndex > 0) {
        selectedSetIndex--;
        renderDetailScreen();
      }
    });

    document.getElementById('btn-next-set').addEventListener('click', () => {
      if (selectedSetIndex < currentSets.length - 1) {
        selectedSetIndex++;
        renderDetailScreen();
      }
    });

    document.getElementById('toggle-two-card-hint').addEventListener('change', (e) => {
      twoCardHintOnly = e.target.checked;
      renderDetailScreen();
    });

    const modal = document.getElementById('scenario-modal');
    document.getElementById('btn-open-scenarios').addEventListener('click', () => modal.classList.add('open'));
    document.getElementById('btn-manual-solver').addEventListener('click', () => {
      showScreen(currentSets.length > 0 ? 'screen-03' : 'screen-05');
      openCardEditModal(0);
    });
    document.getElementById('btn-close-modal').addEventListener('click', () => modal.classList.remove('open'));

    // Single-Card Tap-to-Edit Modal Logic
    const editModal = document.getElementById('card-edit-modal');
    const editTitle = document.getElementById('card-edit-title');
    const editPreview = document.getElementById('card-edit-preview');
    const deleteBtn = document.getElementById('btn-delete-card');

    function syncCardEditUi() {
      const label = String(editingCardIndex + 1).padStart(2, '0');
      editTitle.textContent = `카드 ${label} 속성 수정`;
      editPreview.innerHTML = createPlayingCardHtml(draftCard, {
        badge: label,
        highlightColor: '#06B6D4',
        width: 108,
        height: 92,
      });
      document.querySelectorAll('#card-edit-modal .attr-options').forEach((group) => {
        const attr = group.getAttribute('data-attr');
        group.querySelectorAll('.attr-pill').forEach((pill) => {
          const val = parseInt(pill.getAttribute('data-val'), 10);
          pill.classList.toggle('active', draftCard[attr] === val);
        });
      });
      deleteBtn.disabled = currentCards.length <= 3;
      deleteBtn.style.opacity = currentCards.length <= 3 ? '0.4' : '1';
    }

    function openCardEditModal(idx) {
      editingCardIndex = idx;
      const target = currentCards[idx] || { number: 1, shape: 1, color: 1, shading: 1 };
      draftCard = { ...target };
      syncCardEditUi();
      editModal.classList.add('open');
    }

    ['result-grid', 'detail-grid', 'empty-grid'].forEach((gridId) => {
      const gridEl = document.getElementById(gridId);
      if (!gridEl) return;
      gridEl.addEventListener('click', (e) => {
        const addBtn = e.target.closest('[data-add-card]');
        if (addBtn && currentCards.length < 12) {
          currentCards.push({ number: 1, shape: 1, color: 1, shading: 1 });
          openCardEditModal(currentCards.length - 1);
          return;
        }
        const slot = e.target.closest('[data-card-index]');
        if (!slot) return;
        const idx = parseInt(slot.getAttribute('data-card-index'), 10);
        if (!Number.isNaN(idx)) openCardEditModal(idx);
      });
    });

    document.querySelectorAll('#card-edit-modal .attr-options').forEach((group) => {
      const attr = group.getAttribute('data-attr');
      group.querySelectorAll('.attr-pill').forEach((pill) => {
        pill.addEventListener('click', () => {
          draftCard[attr] = parseInt(pill.getAttribute('data-val'), 10);
          syncCardEditUi();
        });
      });
    });

    document.getElementById('btn-close-card-edit').addEventListener('click', () => {
      editModal.classList.remove('open');
    });

    document.getElementById('btn-save-card').addEventListener('click', () => {
      currentCards[editingCardIndex] = { ...draftCard };
      currentSets = findSets(currentCards);
      if (selectedSetIndex >= currentSets.length) selectedSetIndex = 0;
      editModal.classList.remove('open');
      renderAllBoards();
      const activeScreen = document.querySelector('.screen.active');
      const activeId = activeScreen ? activeScreen.id : 'screen-03';
      if (currentSets.length === 0) {
        showScreen('screen-05');
      } else if (activeId === 'screen-05') {
        showScreen('screen-03');
      } else if (activeId === 'screen-04') {
        showScreen('screen-04');
      }
    });

    deleteBtn.addEventListener('click', () => {
      if (currentCards.length <= 3) return;
      currentCards.splice(editingCardIndex, 1);
      currentSets = findSets(currentCards);
      selectedSetIndex = 0;
      editModal.classList.remove('open');
      renderAllBoards();
      showScreen(currentSets.length > 0 ? 'screen-03' : 'screen-05');
    });

    document.getElementById('btn-scenario-3sets').addEventListener('click', () => {
      modal.classList.remove('open');
      currentCards = getFigmaPresetCards();
      currentSets = findSets(currentCards);
      selectedSetIndex = 0;
      renderAllBoards();
      showScreen('screen-03');
    });

    document.getElementById('btn-scenario-0sets').addEventListener('click', () => {
      modal.classList.remove('open');
      renderAllBoards();
      showScreen('screen-05');
    });

    document.getElementById('btn-scenario-quality').addEventListener('click', () => {
      modal.classList.remove('open');
      showScreen('screen-05b');
    });
  });
})();
