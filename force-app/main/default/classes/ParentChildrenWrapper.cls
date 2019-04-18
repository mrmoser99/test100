/**
 * Author: Cloud Lending Solutions
 * Description: Following class helps in inserting both parent and child objects in one go
 **/
public with sharing class ParentChildrenWrapper {
	public SObject parent;
    public Map<List<sobject>, String> newChildrenMap;

    public ParentChildrenWrapper(SObject parent, Map<List<sobject>, String> newChildrenMap) {
        this.parent = parent;
        this.newChildrenMap = newChildrenMap;
    }

    public List<sobject> getNewChildrenMap(){
        List<sobject> children = new List<sobject>();
        Set<List<sobject>> keys = newChildrenMap.keySet();
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
        // return if list of objects null or size = 0
        if (wrappers  == null || wrappers.size() == 0) {
        	return;
        }
        	
        Savepoint sp = Database.setSavepoint();
        try {
            List<sobject> parents = new List<sobject>();
            for (ParentChildrenWrapper wrapper : wrappers) {
                parents.add(wrapper.parent);
            }
            // Inserting Parent Object
            if (parents.size() > 0) {
                insert parents;
                // Inserting Child objects with parent lik updated
                List<sobject> newChildren = new List<sobject>();
                for (ParentChildrenWrapper wrapper : wrappers) {
                    newChildren.addAll(wrapper.getLinkedChildren(wrapper.newChildrenMap));
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