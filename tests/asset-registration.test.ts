import { describe, it, expect, beforeEach } from 'vitest';

// Mock implementation for testing Clarity contracts
// In a real environment, you would use actual Clarity testing tools

describe('Asset Registration Contract', () => {
  let mockAssets = new Map();
  let lastAssetId = 0;
  
  // Mock functions to simulate contract behavior
  const registerAsset = (name, type, value, condition, sender) => {
    const newId = lastAssetId + 1;
    lastAssetId = newId;
    
    mockAssets.set(newId, {
      name,
      type,
      value,
      condition,
      owner: sender,
      isAvailable: true
    });
    
    return { ok: newId };
  };
  
  const getAsset = (assetId) => {
    return mockAssets.get(assetId) || null;
  };
  
  const updateAsset = (assetId, name, type, value, condition, isAvailable, sender) => {
    const asset = mockAssets.get(assetId);
    if (!asset) return { err: 404 };
    if (asset.owner !== sender) return { err: 403 };
    
    mockAssets.set(assetId, {
      name,
      type,
      value,
      condition,
      owner: sender,
      isAvailable
    });
    
    return { ok: true };
  };
  
  const isAssetAvailable = (assetId) => {
    const asset = mockAssets.get(assetId);
    return asset ? asset.isAvailable : false;
  };
  
  beforeEach(() => {
    mockAssets.clear();
    lastAssetId = 0;
  });
  
  it('should register a new asset', () => {
    const result = registerAsset('Commercial Oven', 'Cooking', 5000, 'New', 'owner1');
    expect(result.ok).toBe(1);
    
    const asset = getAsset(1);
    expect(asset).not.toBeNull();
    expect(asset.name).toBe('Commercial Oven');
    expect(asset.type).toBe('Cooking');
    expect(asset.value).toBe(5000);
    expect(asset.condition).toBe('New');
    expect(asset.owner).toBe('owner1');
    expect(asset.isAvailable).toBe(true);
  });
  
  it('should update an asset', () => {
    registerAsset('Commercial Oven', 'Cooking', 5000, 'New', 'owner1');
    
    const result = updateAsset(1, 'Commercial Oven XL', 'Cooking', 6000, 'Like New', false, 'owner1');
    expect(result.ok).toBe(true);
    
    const asset = getAsset(1);
    expect(asset.name).toBe('Commercial Oven XL');
    expect(asset.value).toBe(6000);
    expect(asset.condition).toBe('Like New');
    expect(asset.isAvailable).toBe(false);
  });
  
  it('should not allow unauthorized updates', () => {
    registerAsset('Commercial Oven', 'Cooking', 5000, 'New', 'owner1');
    
    const result = updateAsset(1, 'Commercial Oven XL', 'Cooking', 6000, 'Like New', false, 'owner2');
    expect(result.err).toBe(403);
    
    const asset = getAsset(1);
    expect(asset.name).toBe('Commercial Oven');
  });
  
  it('should check if asset is available', () => {
    registerAsset('Commercial Oven', 'Cooking', 5000, 'New', 'owner1');
    expect(isAssetAvailable(1)).toBe(true);
    
    updateAsset(1, 'Commercial Oven', 'Cooking', 5000, 'New', false, 'owner1');
    expect(isAssetAvailable(1)).toBe(false);
  });
});
