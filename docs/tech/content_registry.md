# 物品注册与内容管理

游戏中的所有静态内容（物品、配方等）都通过一个中心化的注册系统进行管理。

## 内容管理器 (Contents)

`Contents` 类是游戏内容的单例仓库，负责：

1. **静态注册**：在游戏启动时加载所有预定义的物品和配方。
2. **按名查询**：通过唯一的字符串名称检索物品原型。
3. **分类索引**：维护不同类型内容的列表（如所有食物、所有工具）。

## 物品定义模式

物品通常在专门的注册文件中定义，使用流式 API 或构造函数进行配置。

### 伪代码示例：物品注册

```typescript
interface ItemDefinition {
  name: string;
  mass: number;
  mergeable: boolean;
  tags: string[];
  components: Component[];
}

// 注册示例
const Berry = new ItemDefinition({
  name: "berry",
  mass: 10,
  mergeable: true,
  tags: ["food", "fruit"],
  components: [
    new FreshnessComponent({ maxLife: 48 * 60 }), // 48小时新鲜度
    new UsableComponent({
      onUse: (player) => player.modifyAttribute("hunger", 5)
    })
  ]
});

Contents.registerItem(Berry);
```

## 标签系统 (Tagging System)

标签是内容管理的重要组成部分，用于解耦逻辑：

* **配方匹配**：配方可以要求“任何具有 `fire_starter` 标签的物品”，而不是特定的“打火机”。
* **动作过滤**：某些地点可能只允许丢弃具有 `trash` 标签的物品。
* **UI 过滤**：在背包中按标签筛选物品。
