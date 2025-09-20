# Track My Money - Functional Test Cases

## 🎯 **PRACTICAL TEST CASES FOR APP TESTING**

### **1. APP LAUNCH & FIRST TIME EXPERIENCE**

#### **Test Case 1.1: First Launch**
**Steps:**
1. Uninstall app completely
2. Install fresh app
3. Launch app

**Expected Result:** 
- Shows onboarding screen with 4 pages
- Skip button visible
- Done button visible

**Test:** ✅ Pass

#### **Test Case 1.2: Complete Onboarding** 
**Steps:**
1. Swipe through all 4 onboarding pages
2. Tap "Done" button

**Expected Result:**
- Goes to main app screen
- Shows home tab with balance display

**Test:** ✅ Pass

#### **Test Case 1.3: Skip Onboarding**
**Steps:**
1. On onboarding screen, tap "Skip"

**Expected Result:**
- Goes directly to main app screen

**Test:** ✅ Pass
---

### **2. TRANSACTION MANAGEMENT**

#### **Test Case 2.1: Add Income Transaction**
**Steps:**
1. Tap "+" button on home screen
2. Select "Income" tab
3. Enter amount: "5000"
4. Select category: "Salary"
5. Select date: Today's date
6. Add note: "Monthly salary"
7. Tap "Save"

**Expected Result:**
- Success popup shows: "Transaction Saved!" with green checkmark
- Popup cannot be dismissed by tapping outside (must tap Continue)
- After tapping "Continue", wait 1.5 seconds, then interstitial ad shows
- App continues working after ad closes
- Balance increases by 5000
- Transaction appears in recent transactions list

**Test:** ✅ Pass

#### **Test Case 2.2: Add Expense Transaction**
**Steps:**
1. Tap "+" button on home screen
2. Select "Expense" tab
3. Enter amount: "500"
4. Select category: "Food"
5. Select date: Today's date
6. Add note: "Lunch"
7. Tap "Save"

**Expected Result:**
- Success popup shows: "Transaction Saved!" with green checkmark
- Popup cannot be dismissed by tapping outside (must tap Continue)
- After tapping "Continue", wait 1.5 seconds, then interstitial ad shows
- App continues working after ad closes
- Balance decreases by 500
- Transaction appears in recent transactions list

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 2.3: Edit Transaction**
**Steps:**
1. Go to Transactions tab
2. Tap on any transaction
3. Change amount to "1000"
4. Change note to "Updated note"
5. Tap "Save"

**Expected Result:**
- Success popup shows: "Transaction Updated!" with green checkmark
- After tapping "Continue", interstitial ad shows
- App continues working after ad closes
- Transaction updated successfully
- Balance recalculated correctly
- Updated transaction shows in list

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 2.4: Delete Transaction**
**Steps:**
1. Go to Transactions tab
2. Long press on any transaction
3. Tap "Delete"
4. Confirm deletion

**Expected Result:**
- Transaction deleted successfully
- Balance recalculated correctly
- Transaction removed from list

**Test:** ✅ Pass / ❌ Fail

---

### **3. BALANCE & CALCULATIONS**

#### **Test Case 3.1: Check Balance Calculation**
**Steps:**
1. Add income: 10000
2. Add expense: 3000
3. Add expense: 2000
4. Check balance on home screen

**Expected Result:**
- Balance shows: 5000 (10000 - 3000 - 2000)

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 3.2: Multiple Transactions Balance**
**Steps:**
1. Add 5 income transactions (1000 each)
2. Add 3 expense transactions (500 each)
3. Check final balance

**Expected Result:**
- Balance shows: 3500 (5000 - 1500)

**Test:** ✅ Pass / ❌ Fail

---

### **4. CATEGORIES & FILTERING**

#### **Test Case 4.1: Category Filtering**
**Steps:**
1. Add transactions with different categories (Food, Transport, Shopping)
2. Go to Transactions tab
3. Tap filter icon
4. Select "Food" category

**Expected Result:**
- Only food transactions shown
- Other transactions hidden

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 4.2: Date Filtering**
**Steps:**
1. Add transactions on different dates
2. Go to Transactions tab
3. Tap filter icon
4. Select date range

**Expected Result:**
- Only transactions within date range shown

**Test:** ✅ Pass / ❌ Fail

---

### **5. EXPORT FEATURE**

#### **Test Case 5.1: Export CSV with Date Range**
**Steps:**
1. Add some transactions
2. Go to Home screen
3. Tap "Export (CSV)" button
4. Select date range (e.g., last 30 days)
5. Tap "Watch Ad & Export"
6. Watch rewarded ad
7. Complete export

**Expected Result:**
- Date range picker opens
- Rewarded ad shows
- CSV file generated successfully
- Success message with file path shown

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 5.2: Export Without Watching Ad**
**Steps:**
1. Tap "Export (CSV)" button
2. Select date range
3. Tap "Cancel" when ad dialog shows

**Expected Result:**
- Export cancelled
- No CSV file generated

**Test:** ✅ Pass / ❌ Fail

---

### **6. TEMPLATES**

#### **Test Case 6.1: Create Template**
**Steps:**
1. Go to Templates screen
2. Tap "+" button
3. Enter name: "Monthly Rent"
4. Select category: "Housing"
5. Enter amount: "2000"
6. Tap "Save"

**Expected Result:**
- Success popup shows: "Template Added!" with green checkmark
- Popup cannot be dismissed by tapping outside (must tap Continue)
- After tapping "Continue", wait 1.5 seconds, then interstitial ad shows
- App continues working after ad closes
- Template created successfully
- Template appears in list

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 6.2: Use Template**
**Steps:**
1. Go to Templates screen
2. Tap on "Monthly Rent" template
3. Confirm transaction creation

**Expected Result:**
- Transaction created from template
- Amount and category pre-filled
- Transaction appears in list

**Test:** ✅ Pass / ❌ Fail

---

### **7. REPORTS & CHARTS**

#### **Test Case 7.1: Pie Chart Display**
**Steps:**
1. Add transactions with different categories
2. Go to Reports tab
3. Check pie chart

**Expected Result:**
- Pie chart shows expense breakdown by category
- Colors are different for each category
- Percentages are accurate

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 7.2: Bar Chart Display**
**Steps:**
1. Add transactions over different months
2. Go to Reports tab
3. Check bar chart

**Expected Result:**
- Bar chart shows income vs expenses over time
- Data is accurate and up-to-date

**Test:** ✅ Pass / ❌ Fail

---

### **8. SETTINGS & PREFERENCES**

#### **Test Case 8.1: Change Currency**
**Steps:**
1. Go to Settings tab
2. Tap "Select Currency"
3. Select "USD ($)"
4. Go back to home screen

**Expected Result:**
- Currency changed to USD
- All amounts show $ symbol
- Currency persists after app restart

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 8.2: Share App**
**Steps:**
1. Go to Settings tab
2. Tap "Share App"

**Expected Result:**
- Share dialog opens
- App link included in share message

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 8.3: Rate Us**
**Steps:**
1. Go to Settings tab
2. Tap "Rate Us"

**Expected Result:**
- Play Store page opens in browser/app

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 8.4: Feedback**
**Steps:**
1. Go to Settings tab
2. Tap "Feedback / Suggestions"

**Expected Result:**
- Email client opens
- Email address pre-filled: munexa.studios@gmail.com
- Subject pre-filled: "Expense Tracker App Feedback"

**Test:** ✅ Pass / ❌ Fail

---

### **9. ADMOB INTEGRATION**

#### **Test Case 9.1: Banner Ads**
**Steps:**
1. Navigate through all screens (Home, Transactions, Reports, Settings, Templates)
2. Check bottom of each screen

**Expected Result:**
- Banner ads display on all screens
- Ads don't interfere with app functionality
- Ads load within reasonable time

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 9.2: Interstitial Ads**
**Steps:**
1. Add a new transaction
2. Save transaction

**Expected Result:**
- Success popup shows first with transaction confirmation
- Popup cannot be dismissed by tapping outside (must tap Continue)
- After tapping "Continue", wait 1.5 seconds, then interstitial ad shows
- App continues working after ad closes

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 9.3: Rewarded Ads**
**Steps:**
1. Try to export CSV
2. Watch rewarded ad

**Expected Result:**
- Rewarded ad shows before export
- Export completes after watching ad
- App continues working after ad

**Test:** ✅ Pass / ❌ Fail

---

### **10. NAVIGATION & UI**

#### **Test Case 10.1: Bottom Navigation**
**Steps:**
1. Tap each tab: Home, Transactions, Reports, Settings
2. Check tab switching

**Expected Result:**
- Smooth transition between tabs
- Correct screen loads for each tab
- Tab labels show below icons
- Selected tab highlighted

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 10.2: Empty States**
**Steps:**
1. Delete all transactions
2. Check home screen

**Expected Result:**
- Shows helpful empty state message
- Icon and text displayed
- "No transactions yet" message

**Test:** ✅ Pass / ❌ Fail

---

### **11. DATA PERSISTENCE**

#### **Test Case 11.1: App Restart**
**Steps:**
1. Add some transactions
2. Close app completely
3. Reopen app

**Expected Result:**
- All transactions still present
- Balance calculated correctly
- Settings preserved

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 11.2: Settings Persistence**
**Steps:**
1. Change currency to USD
2. Close app
3. Reopen app

**Expected Result:**
- Currency still set to USD
- All settings preserved

**Test:** ✅ Pass / ❌ Fail

---

### **12. ERROR HANDLING**

#### **Test Case 12.1: Invalid Amount**
**Steps:**
1. Try to add transaction with amount: "abc"
2. Tap Save

**Expected Result:**
- Error message shown
- Transaction not saved

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 12.2: Empty Fields**
**Steps:**
1. Try to add transaction without amount
2. Tap Save

**Expected Result:**
- Error message shown
- Transaction not saved

**Test:** ✅ Pass / ❌ Fail

---

### **13. GOOGLE PLAY STORE COMPLIANCE**

#### **Test Case 13.1: Ad Timing Compliance**
**Steps:**
1. Add a new transaction
2. Save transaction
3. Check timing between success popup and ad

**Expected Result:**
- Success popup shows immediately after saving
- After tapping "Continue", there's a 1.5 second delay
- Interstitial ad shows only after the delay
- This complies with Google Play Store policies about ad timing

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 13.2: User Action Confirmation**
**Steps:**
1. Add a new transaction
2. Save transaction
3. Try to dismiss popup by tapping outside

**Expected Result:**
- Success popup shows and cannot be dismissed by tapping outside
- User must tap "Continue" to proceed
- This ensures user sees confirmation before any ads

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 13.3: Popup UI Display**
**Steps:**
1. Add a new transaction
2. Save transaction
3. Check popup appearance

**Expected Result:**
- Success popup shows without any overflow errors
- No yellow/black striped patterns on popup edges
- Text fits properly within popup boundaries
- Popup is properly centered and responsive

**Test:** ✅ Pass / ❌ Fail

#### **Test Case 13.4: Navigation and Data Refresh**
**Steps:**
1. Add a new transaction
2. Save transaction
3. Check navigation flow

**Expected Result:**
- Success popup shows
- After tapping Continue, interstitial ad appears
- After ad closes, returns to home page
- New transaction appears instantly in home page
- Balance updates immediately
- No navigation issues or stuck screens

**Test:** ✅ Pass / ❌ Fail

---

## 🎯 **TESTING CHECKLIST**

### **Before Testing:**
- [ ] App is freshly installed
- [ ] Internet connection available
- [ ] Test device ready

### **After Testing:**
- [ ] All test cases completed
- [ ] Bugs documented
- [ ] Screenshots taken (if needed)

### **Bug Reporting:**
```
**Bug Found:** [Yes/No]
**Test Case:** [Which test case failed]
**Steps:** [What you did]
**Expected:** [What should happen]
**Actual:** [What actually happened]
**Device:** [Your device]
**Screenshot:** [If applicable]
```

---

**Happy Testing! Let me know what you find! 🚀** 