public class ParentChildrenWrapper {
    public SObject parent;
    public Map<List<sobject>, String> newChildrenMap;
    public Map<List<sobject>, String> newChildren2Map;

    public ParentChildrenWrapper(SObject parent,
                        Map<List<sobject>, String> newChildrenMap,
                        Map<List<sobject>, String> newChildren2Map) {
        this.parent = parent;
        this.newChildrenMap = newChildrenMap;
        this.newChildren2Map = newChildren2Map;
    }

    public List<sobject> getNewChildrenMap(){
        List<sobject> children = new List<sobject>();
        Set<List<sobject>> keys = newChildrenMap.keySet();
        for (List<sobject> key : keys) {
            children.addAll(key);
        }
        return children;
    }

    public List<sobject> getNewChildren2Map(){
        List<sobject> children = new List<sobject>();
        Set<List<sobject>> keys = newChildren2Map.keySet();
        for (List<sobject> key : keys) {
            children.addAll(key);
        }
        return children;
    }

    private List<sobject> getLinkedChildren(Map<List<sobject>, String> childrenMap) {
        List<sobject> children = new List<sobject>();
        if (parent != null) {
            if (childrenMap != null) {
                Set<List<sobject>> keys = childrenMap.keySet();
                for (List<sobject> key : keys) {
                    String parentIdFieldName = childrenMap.get(key);
                    if (parentIdFieldName != null) {
                        for (sobject obj : key) {
                            obj.put(parentIdFieldName, this.parent.Id);
                            children.add(obj);
                        }
                    }
                }
            }
        }
        return children;
    }

    public static void upsertWrappers(List<ParentChildrenWrapper> wrappers) {
        if (wrappers != null && wrappers.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            try {
                List<sobject> parents = new List<sobject>();
                for (ParentChildrenWrapper wrapper : wrappers) {
                    parents.add(wrapper.parent);
                }

                if (parents.size() > 0) {
                    insert parents;

                    // 1. Processing newChildrenMap
                    List<sobject> newChildren = new List<sobject>();
                    for (ParentChildrenWrapper wrapper : wrappers) {
                        newChildren.addAll(wrapper.getLinkedChildren(wrapper.newChildrenMap));
                    }
                    if (newChildren.size() > 0) {
                        insert newChildren;
                        System.debug('Inserted new children');
                    }

                    // 2. Processing newChildren2Map
                    newChildren = new List<sobject>();
                    for (ParentChildrenWrapper wrapper : wrappers) {
                        newChildren.addAll(wrapper.getLinkedChildren(wrapper.newChildren2Map));
                    }
                    if (newChildren.size() > 0) {
                        insert newChildren;
                    }
                }
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug(e.getMessage());
                throw(e);
            }
        }
    }
}