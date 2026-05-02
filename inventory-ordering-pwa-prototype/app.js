const STORAGE_KEY = 'stockflow-prototype-v1';

const seedAccounts = [
  { username: 'admin', password: 'admin123', role: 'admin', displayName: '總部主帳號' },
  { username: 'taipei01', password: 'store123', role: 'store', displayName: '台北一店' },
  { username: 'taichung01', password: 'store123', role: 'store', displayName: '台中店' },
  { username: 'kaohsiung01', password: 'store123', role: 'store', displayName: '高雄店' },
];

const seedItems = [
  { id: uid(), sku: 'DRK-001', name: '招牌紅茶', category: '飲品原料', unit: '箱', currentStock: 28, safetyStock: 18 },
  { id: uid(), sku: 'MIL-002', name: '鮮奶基底', category: '冷藏原料', unit: '箱', currentStock: 12, safetyStock: 16 },
  { id: uid(), sku: 'CUP-003', name: '中杯紙杯', category: '包材', unit: '包', currentStock: 48, safetyStock: 25 },
  { id: uid(), sku: 'TOP-004', name: '珍珠配料', category: '配料', unit: '桶', currentStock: 9, safetyStock: 14 },
];

const state = loadState();
let currentUser = null;
let deferredPrompt = null;

const els = {
  pageTitle: document.getElementById('pageTitle'),
  navLinks: [...document.querySelectorAll('.nav-link')],
  views: [...document.querySelectorAll('.view')],
  navAdmin: document.getElementById('navAdmin'),
  navStore: document.getElementById('navStore'),
  userPill: document.getElementById('userPill'),
  logoutBtn: document.getElementById('logoutBtn'),
  installBtn: document.getElementById('installBtn'),
  installStatus: document.getElementById('installStatus'),

  loginForm: document.getElementById('loginForm'),
  loginMessage: document.getElementById('loginMessage'),
  username: document.getElementById('username'),
  password: document.getElementById('password'),

  itemForm: document.getElementById('itemForm'),
  itemSku: document.getElementById('itemSku'),
  itemName: document.getElementById('itemName'),
  itemCategory: document.getElementById('itemCategory'),
  itemUnit: document.getElementById('itemUnit'),
  itemCurrentStock: document.getElementById('itemCurrentStock'),
  itemSafetyStock: document.getElementById('itemSafetyStock'),
  itemTableBody: document.getElementById('itemTableBody'),
  orderTableBody: document.getElementById('orderTableBody'),
  submissionCards: document.getElementById('submissionCards'),
  metricItemCount: document.getElementById('metricItemCount'),
  metricStoreCount: document.getElementById('metricStoreCount'),
  metricOrderCount: document.getElementById('metricOrderCount'),
  seedDataBtn: document.getElementById('seedDataBtn'),
  exportDataBtn: document.getElementById('exportDataBtn'),
  resetDataBtn: document.getElementById('resetDataBtn'),
  importFileInput: document.getElementById('importFileInput'),
  refreshAdminBtn: document.getElementById('refreshAdminBtn'),

  storeNameMetric: document.getElementById('storeNameMetric'),
  storeItemCount: document.getElementById('storeItemCount'),
  storeLastSubmit: document.getElementById('storeLastSubmit'),
  storeItemsContainer: document.getElementById('storeItemsContainer'),
  storeRequestForm: document.getElementById('storeRequestForm'),
  storeHistory: document.getElementById('storeHistory'),
  storeMessage: document.getElementById('storeMessage'),
  storeNote: document.getElementById('storeNote'),
  prefillBtn: document.getElementById('prefillBtn'),
};

boot();

function boot() {
  bindEvents();
  renderCurrentSession();
  registerServiceWorker();
}

function bindEvents() {
  els.navLinks.forEach((button) => {
    button.addEventListener('click', () => setView(button.dataset.view));
  });

  els.loginForm.addEventListener('submit', handleLogin);
  els.logoutBtn.addEventListener('click', logout);
  els.itemForm.addEventListener('submit', handleAddItem);
  els.seedDataBtn.addEventListener('click', loadDemoItems);
  els.exportDataBtn.addEventListener('click', exportJson);
  els.resetDataBtn.addEventListener('click', resetAppData);
  els.importFileInput.addEventListener('change', importJson);
  els.refreshAdminBtn.addEventListener('click', renderAdminDashboard);
  els.storeRequestForm.addEventListener('submit', handleStoreSubmit);
  els.prefillBtn.addEventListener('click', prefillStoreQuantities);

  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferredPrompt = event;
    els.installBtn.classList.remove('hidden');
    els.installStatus.textContent = '可安裝成手機桌面 App';
  });

  els.installBtn.addEventListener('click', async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    await deferredPrompt.userChoice;
    deferredPrompt = null;
    els.installBtn.classList.add('hidden');
    els.installStatus.textContent = '已觸發安裝提示';
  });
}

function renderCurrentSession() {
  const savedUser = sessionStorage.getItem('stockflow-current-user');
  if (savedUser) {
    currentUser = JSON.parse(savedUser);
  }
  updateNavForRole();
  renderAll();
}

function handleLogin(event) {
  event.preventDefault();
  const username = els.username.value.trim();
  const password = els.password.value.trim();
  const user = state.accounts.find((account) => account.username === username && account.password === password);

  if (!user) {
    showMessage(els.loginMessage, '帳號或密碼錯誤，請重新輸入。', true);
    return;
  }

  currentUser = user;
  sessionStorage.setItem('stockflow-current-user', JSON.stringify(user));
  showMessage(els.loginMessage, `登入成功：${user.displayName}`);
  updateNavForRole();
  renderAll();

  if (user.role === 'admin') {
    setView('adminView');
  } else {
    setView('storeView');
  }

  els.loginForm.reset();
}

function logout() {
  currentUser = null;
  sessionStorage.removeItem('stockflow-current-user');
  updateNavForRole();
  renderAll();
  setView('loginView');
}

function updateNavForRole() {
  const isAdmin = currentUser?.role === 'admin';
  const isStore = currentUser?.role === 'store';

  els.navAdmin.classList.toggle('hidden', !isAdmin);
  els.navStore.classList.toggle('hidden', !isStore);
  els.userPill.classList.toggle('hidden', !currentUser);
  els.logoutBtn.classList.toggle('hidden', !currentUser);
  els.userPill.textContent = currentUser ? `${currentUser.displayName}｜${currentUser.role === 'admin' ? '主帳號' : '分店帳號'}` : '';
}

function setView(viewId) {
  els.views.forEach((view) => view.classList.toggle('active', view.id === viewId));
  els.navLinks.forEach((link) => link.classList.toggle('active', link.dataset.view === viewId));

  const titles = {
    loginView: '登入系統',
    adminView: '主帳號後台',
    storeView: '分店回報',
    aboutView: '系統說明',
  };
  els.pageTitle.textContent = titles[viewId] || 'StockFlow Pro';
}

function renderAll() {
  renderAdminDashboard();
  renderStoreDashboard();
}

function renderAdminDashboard() {
  const items = state.items;
  const stores = state.accounts.filter((account) => account.role === 'store');
  const orderRows = calculateOrderRows();

  els.metricItemCount.textContent = items.length;
  els.metricStoreCount.textContent = stores.length;
  els.metricOrderCount.textContent = orderRows.filter((row) => row.suggestedOrder > 0).length;

  els.itemTableBody.innerHTML = items.map((item) => `
    <tr>
      <td>${escapeHtml(item.sku)}</td>
      <td>${escapeHtml(item.name)}</td>
      <td>${escapeHtml(item.category)}</td>
      <td>${escapeHtml(item.unit)}</td>
      <td>${item.currentStock}</td>
      <td>${item.safetyStock}</td>
      <td>
        <button class="secondary-btn" onclick="window.editItem('${item.id}')">編輯</button>
        <button class="danger-btn" onclick="window.deleteItem('${item.id}')">刪除</button>
      </td>
    </tr>
  `).join('');

  els.orderTableBody.innerHTML = orderRows.map((row) => `
    <tr>
      <td>${escapeHtml(row.sku)}</td>
      <td>${escapeHtml(row.name)}</td>
      <td>${row.totalDemand}</td>
      <td>${row.safetyStock}</td>
      <td>${row.currentStock}</td>
      <td><strong>${row.suggestedOrder}</strong></td>
    </tr>
  `).join('');

  const submissions = [...state.submissions].sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt));
  els.submissionCards.innerHTML = submissions.length
    ? submissions.map((submission) => {
        const store = state.accounts.find((account) => account.username === submission.storeUsername);
        return `
          <article class="submission-card">
            <h4>${escapeHtml(store?.displayName || submission.storeUsername)}</h4>
            <p class="submission-meta">送出時間：${formatDate(submission.submittedAt)}</p>
            <p class="submission-meta">備註：${escapeHtml(submission.note || '無')}</p>
            <div class="submission-items">
              ${submission.entries.filter((entry) => entry.quantity > 0).map((entry) => {
                const item = state.items.find((product) => product.id === entry.itemId);
                return `<span class="chip">${escapeHtml(item?.name || '已刪除品項')} × ${entry.quantity}</span>`;
              }).join('') || '<span class="chip">本次無填寫數量</span>'}
            </div>
          </article>
        `;
      }).join('')
    : '<div class="helper-card">目前還沒有分店回報資料。</div>';
}

function renderStoreDashboard() {
  const items = state.items;
  els.storeItemCount.textContent = items.length;
  els.storeNameMetric.textContent = currentUser?.displayName || '-';

  const myLatest = currentUser
    ? [...state.submissions]
        .filter((submission) => submission.storeUsername === currentUser.username)
        .sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt))[0]
    : null;

  els.storeLastSubmit.textContent = myLatest ? formatDate(myLatest.submittedAt, true) : '未送出';

  els.storeItemsContainer.innerHTML = items.length
    ? items.map((item) => `
      <div class="store-item-card">
        <div class="store-item-header">
          <div>
            <strong>${escapeHtml(item.name)}</strong>
            <div class="store-item-meta">${escapeHtml(item.sku)}｜${escapeHtml(item.category)}｜單位：${escapeHtml(item.unit)}</div>
          </div>
          <div class="store-item-meta">總部安全庫存：${item.safetyStock}</div>
        </div>
        <div>
          <label>
            <span>本店需求數量</span>
            <input class="qty-input" type="number" min="0" step="1" data-item-id="${item.id}" placeholder="輸入數量" value="${getLatestSubmittedQty(item.id)}" />
          </label>
        </div>
      </div>
    `).join('')
    : '<div class="helper-card">目前尚未建立任何貨品，請先由主帳號建立貨單。</div>';

  els.storeHistory.innerHTML = currentUser
    ? [...state.submissions]
        .filter((submission) => submission.storeUsername === currentUser.username)
        .sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt))
        .slice(0, 5)
        .map((submission) => `
          <article class="history-card">
            <strong>${formatDate(submission.submittedAt)}</strong>
            <p>備註：${escapeHtml(submission.note || '無')}</p>
            <div class="submission-items">
              ${submission.entries.filter((entry) => entry.quantity > 0).map((entry) => {
                const item = state.items.find((product) => product.id === entry.itemId);
                return `<span class="chip">${escapeHtml(item?.name || '已刪除品項')} × ${entry.quantity}</span>`;
              }).join('') || '<span class="chip">無數量資料</span>'}
            </div>
          </article>
        `).join('') || '<div class="helper-card">本店尚未有送出紀錄。</div>'
    : '<div class="helper-card">請先登入分店帳號。</div>';
}

function handleAddItem(event) {
  event.preventDefault();
  const newItem = {
    id: uid(),
    sku: els.itemSku.value.trim(),
    name: els.itemName.value.trim(),
    category: els.itemCategory.value.trim(),
    unit: els.itemUnit.value.trim(),
    currentStock: Number(els.itemCurrentStock.value),
    safetyStock: Number(els.itemSafetyStock.value),
  };

  if (!newItem.sku || !newItem.name) return;

  state.items.push(newItem);
  persist();
  els.itemForm.reset();
  renderAdminDashboard();
  renderStoreDashboard();
}

window.editItem = function editItem(id) {
  const item = state.items.find((product) => product.id === id);
  if (!item) return;

  const currentStock = prompt(`修改 ${item.name} 的現有庫存`, item.currentStock);
  const safetyStock = prompt(`修改 ${item.name} 的安全庫存`, item.safetyStock);

  if (currentStock === null || safetyStock === null) return;

  item.currentStock = Math.max(0, Number(currentStock) || 0);
  item.safetyStock = Math.max(0, Number(safetyStock) || 0);
  persist();
  renderAdminDashboard();
  renderStoreDashboard();
};

window.deleteItem = function deleteItem(id) {
  const item = state.items.find((product) => product.id === id);
  if (!item) return;
  if (!confirm(`確定要刪除 ${item.name} 嗎？`)) return;

  state.items = state.items.filter((product) => product.id !== id);
  state.submissions = state.submissions.map((submission) => ({
    ...submission,
    entries: submission.entries.filter((entry) => entry.itemId !== id),
  }));
  persist();
  renderAdminDashboard();
  renderStoreDashboard();
};

function handleStoreSubmit(event) {
  event.preventDefault();
  if (!currentUser || currentUser.role !== 'store') {
    showMessage(els.storeMessage, '請先登入分店帳號。', true);
    return;
  }

  const entries = [...document.querySelectorAll('[data-item-id]')].map((input) => ({
    itemId: input.dataset.itemId,
    quantity: Math.max(0, Number(input.value) || 0),
  }));

  const submission = {
    id: uid(),
    storeUsername: currentUser.username,
    note: els.storeNote.value.trim(),
    submittedAt: new Date().toISOString(),
    entries,
  };

  state.submissions.push(submission);
  persist();
  renderStoreDashboard();
  renderAdminDashboard();
  showMessage(els.storeMessage, '分店需求已成功送出。');
}

function prefillStoreQuantities() {
  const inputs = [...document.querySelectorAll('[data-item-id]')];
  inputs.forEach((input, index) => {
    input.value = [2, 4, 6, 3, 1, 5][index % 6];
  });
}

function loadDemoItems() {
  state.items = structuredClone(seedItems);
  state.submissions = [];
  persist();
  renderAll();
}

function exportJson() {
  const blob = new Blob([JSON.stringify(state, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'stockflow-prototype-data.json';
  a.click();
  URL.revokeObjectURL(url);
}

function importJson(event) {
  const file = event.target.files?.[0];
  if (!file) return;

  const reader = new FileReader();
  reader.onload = () => {
    try {
      const imported = JSON.parse(String(reader.result));
      if (!Array.isArray(imported.items) || !Array.isArray(imported.accounts) || !Array.isArray(imported.submissions)) {
        throw new Error('invalid');
      }
      state.items = imported.items;
      state.accounts = imported.accounts;
      state.submissions = imported.submissions;
      persist();
      renderAll();
      alert('JSON 匯入成功。');
    } catch {
      alert('JSON 格式錯誤，請確認檔案內容。');
    }
  };
  reader.readAsText(file, 'utf-8');
}

function resetAppData() {
  if (!confirm('確定要重置為初始資料嗎？')) return;
  localStorage.removeItem(STORAGE_KEY);
  state.items = structuredClone(seedItems);
  state.accounts = structuredClone(seedAccounts);
  state.submissions = [];
  persist();
  renderAll();
}

function calculateOrderRows() {
  return state.items.map((item) => {
    const totalDemand = state.submissions.reduce((sum, submission) => {
      const matched = submission.entries.find((entry) => entry.itemId === item.id);
      return sum + (matched?.quantity || 0);
    }, 0);

    return {
      sku: item.sku,
      name: item.name,
      totalDemand,
      safetyStock: item.safetyStock,
      currentStock: item.currentStock,
      suggestedOrder: Math.max(totalDemand + item.safetyStock - item.currentStock, 0),
    };
  });
}

function getLatestSubmittedQty(itemId) {
  if (!currentUser || currentUser.role !== 'store') return 0;
  const latest = [...state.submissions]
    .filter((submission) => submission.storeUsername === currentUser.username)
    .sort((a, b) => new Date(b.submittedAt) - new Date(a.submittedAt))[0];
  return latest?.entries.find((entry) => entry.itemId === itemId)?.quantity || 0;
}

function loadState() {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (!raw) {
    const initial = {
      accounts: structuredClone(seedAccounts),
      items: structuredClone(seedItems),
      submissions: [],
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(initial));
    return initial;
  }

  try {
    return JSON.parse(raw);
  } catch {
    const fallback = {
      accounts: structuredClone(seedAccounts),
      items: structuredClone(seedItems),
      submissions: [],
    };
    localStorage.setItem(STORAGE_KEY, JSON.stringify(fallback));
    return fallback;
  }
}

function persist() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function showMessage(target, message, isError = false) {
  target.textContent = message;
  target.style.color = isError ? '#fdba74' : '#86efac';
}

function formatDate(value, short = false) {
  const date = new Date(value);
  return new Intl.DateTimeFormat('zh-TW', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: short ? undefined : '2-digit',
    minute: short ? undefined : '2-digit',
  }).format(date);
}

function uid() {
  return Math.random().toString(36).slice(2, 11);
}

function escapeHtml(text) {
  return String(text)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('./sw.js').catch(() => {
      els.installStatus.textContent = '瀏覽器不支援離線快取';
    });
  }
}
